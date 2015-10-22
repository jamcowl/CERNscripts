#!/bin/bash

Inputfile=/home/athomps/MxAOD_h008/run/submittedDatasetsMC_h008_3.txt

#EOSdir=/afs/cern.ch/user/a/athompso/eos/atlas/atlasgroupdisk/phys-higgs/HSG1/MxAOD/h008
EOSdir=root://eosatlas.cern.ch//eos/atlas/atlasgroupdisk/phys-higgs/HSG1/MxAOD/h008/MxAOD
EOSdir2=/eos/atlas/atlasgroupdisk/phys-higgs/HSG1/MxAOD/h008/MxAOD
#tempDir=/afs/cern.ch/work/a/athompso/temp
tempDir=/disk/userdata00/user/athomps
# need to 
export ATLAS_LOCAL_ROOT_BASE=/cvmfs/atlas.cern.ch/repo/ATLASLocalRootBase
source ${ATLAS_LOCAL_ROOT_BASE}/user/atlasLocalSetup.sh
localSetupFAX
localSetupRucioClients
rcSetup -q
echo "8Twmp224tony" | voms-proxy-init -voms atlas
[[ -z $ROOTCOREBIN ]] && echo "you need to setup ROOTCORE!" && exit 1
[[ -z $RUCIO_ACCOUNT ]] && echo "you need to setup RUCIO!" && exit 1

rm output/*
#function CheckAFS {
#    `klist -s` && `kinit athompso@CERN.CH <<< "9Fkgb331"` && aklog
#
#}


while read p; do
    [[ $p == \#* ]] && continue
#    CheckAFS
    #datasetName=$(rucio list-dids ${p}*h008_1_MxAOD.root| grep ".root " | awk '{print $2}')
    datasetName=$(rucio list-dids ${p}*h008_2*| grep "MxAOD.root " | awk '{print $2}')
    [ -z $datasetName ] && echo $p >>output/NotFoundDatasetsDownload.txt && echo "Not Found $p" && continue
    datasetName=${datasetName#*:}
    Output=$(rucio download --dir $tempDir ${datasetName}   |& grep "ERROR")
    
    #    CheckAFS
    Error=$(echo $Output | grep "ERROR") 
    Warning=$(echo $Output | grep "WARNING")
#    echo $Error
    [ ! -z "$Error" ]    && echo $datasetName >>output/failedDatasetsDownload.txt && echo "FAILED $datasetName" && continue
    [ ! -z "$Warning" ]  && echo $datasetName >>output/warningDatasets.txt && echo "WARNING $datasetName" && continue
    echo $datasetName >>output/downloadedDatasets.txt && echo "PASSED $datasetName"
    
    DataDir=$tempDir/$datasetName
    files=$(echo $DataDir/*)
    Nfiles=$(echo $files | awk '{print NF}')
    newDSname=${datasetName#user.athompso.}
    newDSname=${newDSname%_MxAOD.root}.root
    [ ${newDSname: -7} == _1.root  ] && newDSname=${newDSname%_1*}.root   # FIXME this is horrible
    [ ${newDSname: -7} == _2.root  ] && newDSname=${newDSname%_2*}.root
    [ ${newDSname: -7} == _3.root  ] && newDSname=${newDSname%_3*}.root
    [ "$Nfiles" -gt "1" ]  && xAODMerge -b -s $tempDir/$newDSname $files
    [ "$Nfiles" -eq "1" ]  && mv $DataDir/* ${tempDir}/$newDSname
    xrdcp $tempDir/$newDSname $EOSdir/$newDSname && rm $tempDir/$newDSname

    rm -r $tempDir/$datasetName
done < "$Inputfile"


