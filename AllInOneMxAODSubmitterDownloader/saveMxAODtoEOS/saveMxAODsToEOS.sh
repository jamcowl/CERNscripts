#!/bin/bash

#  Given a list of grid output dataset names 
# e.g. user.athompso.user.athompso.Sherpa_gamjet_35-70_CVetoBVeto.MxAOD.p2419.h008
# this script will download them to a temp Directory, merge them if necessarry,
# and copy them to the speicified directories in EOS, also renaming then.  

# Safe Merge solves the problem of when MxAODs cause xAODMerge to segfault, producing
# an output file without a collection tree.  It seems to happen sometimes when you
# try to merge a big file will a small file, and the solution is to merge the small
# file with the big file.  SafeMerge recursively tries to merge files in groups
# of twos, resulting in one fully merged file.

# need ROOTCORE to merge files, need RUCIO to download files
# first time setup:
# setupATLAS
# localSetupRucioClients
# rcSetup Base,2.3.31
#
# after first setup:
# setupATLAS
# rcSetup
#
# Run like source saveMxAODtoEOS.sh FILEPATH

htag="h008"

#EOSdir=/afs/cern.ch/user/a/athompso/eos/atlas/atlasgroupdisk/phys-higgs/HSG1/MxAOD/h008
EOSdir=root://eosatlas.cern.ch//eos/atlas/atlasgroupdisk/phys-higgs/HSG1/MxAOD/$htag
EOSdirAllSys=$EOSdir/MxAODAllSys
EOSdirMC25ns=$EOSdir/mc_25ns
EOSdirMC50ns=$EOSdir/mc_50ns
EOSdirDATA25ns=$EOSdir/data_25ns
EOSdirDATA50ns=$EOSdir/data_50ns
#tempDir=/afs/cern.ch/work/a/athompso/temp
tempDir=/disk/userdata00/user/athomps
# need to setup environment first! 
[[ -z $ROOTCOREBIN ]] && echo "you need to setup ROOTCORE!" && exit 1
[[ -z $RUCIO_ACCOUNT ]] && echo "you need to setup RUCIO!" && exit 1

#rm output/*
#function CheckAFS {
#    `klist -s` && `kinit athompso@CERN.CH <<< "9Fkgb331"` && aklog
#
#}

# loop over input file
while read p; do
    [[ $p == \#* ]] && continue
    EOSdir=$EOSdirMC25ns
    ALLSys=FALSE
    [[ "$p" =~ "MxAODAllSys" ]] && EOSdir=$EOSdirAllSys && AllSys=TRUE
    [[ "$p" =~ "_50ns" ]]  && EOSdir=$EOSdirMC50ns
    if [[ "$p" =~ "data15" ]] ; then
        runN=${p:27:8}
        # runs 267071-271744 are 50 ns runs, runs >= 276262 are 25ns runs (none in between)
        # run 276731 is an evil outlier, it is 50ns hidden in 25ns range
        [ "$runN" -ge "00267073" ] && [ "$runN" -le "00271744" ] && EOSdir=$EOSdirDATA50ns
        [ "$runN" -ge "00276262" ] && EOSdir=$EOSdirDATA25ns
        [ "$runN" -eq "00276731" ] && EOSdir=$EOSdirDATA50ns
    fi

    #datasetName=$(rucio list-dids ${p}*h008_1_MxAOD.root| grep ".root " | awk '{print $2}')
    # get MxAOD part of dataset name from rucio
    datasetName=$(rucio list-dids ${p}*| grep "MxAOD.root " | awk '{print $2}')
    [ -z "$datasetName" ] && echo $p >>output/NotFoundDatasetsDownload.txt && echo "Not Found $p" && continue

    datasetName=${datasetName#*:}
    echo "downloading $datasetName"

    Output=$(rucio download --dir $tempDir ${datasetName}   |& grep "ERROR")
    [ ! -z "$Output" ]    && echo $datasetName >>output/failedDatasetsDownload.txt && echo "FAILED $datasetName" && continue
    echo $datasetName >>output/downloadedDatasets.txt && echo "PASSED $datasetName"
    
    DataDir=$tempDir/$datasetName
    files=$(echo $DataDir/*)
    Nfiles=$(echo $files | awk '{print NF}')
    newDSname=${datasetName#user.athompso.}
    newDSname=${newDSname%_MxAOD.root}.root
    # sometimes labled hXXX_N for resubmitted jobs thanks to grid failures, need to remove
    [[ "${newDSname: -7}" =~ _[0-9].root  ]] && newDSname=${newDSname::${#newDSname}-7}.root
 
    if [ "$Nfiles" -gt "1" ]; then
        # if Nfiles > 1 and is MxAODAllSys file, then xAODMerge will not work and blow up the filesize
        echo more than 1 file in dataset, will merge if not AllSys
        if [ "$AllSys" == TRUE ]; then
          echo big AllSys file detected, will not merge
          i=$(( 1 ))
          for f in $files; do 
            if [[ ${#i} < 2 ]]
            then
              inputNo="00${i}"
              inputNo="${i: -2}"
            fi
            AllSysDSname=${newDSname%.root}.${inputNo}.root
            #mv $f $dataDir/${AllSysDSname}
            xrdcp $f $EOSdirAllSys/$newDSname/${AllSysDSname}
            i=$(( $i + 1 ))
          done
        elif [[ $(xAODMerge -b -s $tempDir/$newDSname $files &>>MergeOutput.out && echo true) == true ]]; then
          echo xAODMerge success! Copying to EOS...
          xrdcp $tempDir/$newDSname $EOSdir/$newDSname && rm $tempDir/$newDSname
        else
          echo xAODMerge failed :\( Safe Merging... This may take a while. \(WHY DOES THIS HAPPEN?!\) 
          # safe merge merges files safely (see description at top or look at SafeMerge.sh)
          OutputFile=$(source SafeMerge.sh $DataDir)
          echo Safe Merge done! #Output file:
          #echo $OutputFile
          echo Copying to EOS...
          xrdcp $OutputFile $EOSdir/$newDSname && rm $OutputFile
          #echo $EOSdir/$newDSname
          echo $newDSname >> safeMerges.out
        fi
    elif [ "$Nfiles" -eq "1" ]; then
        # no need to merge if it's 1 file
        mv $DataDir/* ${tempDir}/$newDSname
        xrdcp $tempDir/$newDSname $EOSdir/$newDSname && rm $tempDir/$newDSname
    fi
    rm -r $tempDir/$datasetName

    #[ "$Nfiles" -eq "1" ]  && mv $DataDir/* ${tempDir}/$newDSname && \
    #  xrdcp $tempDir/$newDSname $EOSdir/$newDSname && rm $tempDir/$newDSname
    #xrdcp $tempDir/$newDSname $EOSdir/$newDSname && rm $tempDir/$newDSname
    #[ ${newDSname: -7} == _1.root  ] && newDSname=${newDSname%_1*}.root   # FIXME this is horrible
    #[ "$Nfiles" -gt "1" ]  && xAODMerge -b -s $tempDir/$newDSname $files && \ 
    #  xrdcp $tempDir/$newDSname $EOSdir/$newDSname && rm $tempDir/$newDSname

done < "$1"
