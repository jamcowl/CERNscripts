#!/bin/bash

scriptName=$0

SetupIssue() {
  echo
  echo "$1"
  echo
  echo "To setup do:"
  echo "  export ATLAS_LOCAL_ROOT_BASE=/cvmfs/atlas.cern.ch/repo/ATLASLocalRootBase"
  echo "  source \${ATLAS_LOCAL_ROOT_BASE}/user/atlasLocalSetup.sh"
  echo "  localSetupRucioClients"
  echo "  rcSetup -q"
  exit 1
}

usage() {
  printf "\n%s\n" "$1"
  printf "\nUsage:\n   %s [OPTIONS] INPUT HTAG CONFIG \n" "$scriptName"
  printf "\nExample:\n  %s -dm periodE h010 MxAOD.config \n" "$scriptName"
  printf "\nExample:\n  %s -dm -o /tmp periodE h003 MxAOD.config \n" "$scriptName"
  printf "\nOPTIONS, -d for downloading files, -m for merging files, -f for official group files \n -o [directory] to specify directory, -e to save to EOS area,\n -g to save to grid area, -h for help, -t [htag] to specify htag for EOS uploading (defaults to one for file)\n\n"
  printf "\nINPUT, see HGamTools/data/input/  examples:\n  periodC, allMC, PowhegPy8_ggH125, PowhegPy8_VBF145 ...\n\n"
  exit 1
}

[[ $# < 3 ]] && usage "Not enough options !"



# arguments...
OPTIND=1
downloadDir=$(pwd)
copyToEOS="false"
mergeFiles="false"
copyToGrid="false" # TODO
official="false"
downloadFiles="false"
EOS_htag=""
while getopts "h?emo:dfgt:" opt; do
    case "$opt" in
    h|\?)
        usage
        ;;
    e)  copyToEOS="true"
        ;;
    m)  mergeFiles="true"
        ;;
    o)  downloadDir=$OPTARG
        ;;
    d)  downloadFiles="true"
        ;;
    f)  official="true"
        ;;
    g)  copyToGrid="true"
        ;;
    t)  EOS_htag=$OPTARG
        ;;
    esac
done

options=()
[[ "$downloadFiles" == "true" ]] && options+=("download")
[[ "$mergeFiles" == "true" ]] && options+=("merge")
[[ "$copyToEOS" == "true" ]] && options+=("EOScopy")
[[ "$official" == "true" ]] && options+=("officialProduction")
[[ "$copyToGrid" == "true" ]] && options+=("GridCopy")
[[ ! -z "$EOS_htag" ]] && options+=("differentEOShtag")

# need to setup environment first! 
[[ "$mergeFiles" == "true" ]] && [[ -z $ROOTCOREBIN ]] && SetupIssue "you need to setup ROOTCORE!"
[[ "$downloadFiles" == "true" ]] && [[ -z $RUCIO_ACCOUNT ]] && SetupIssue "you need to setup RUCIO!"

sample=${@:$OPTIND:1}
htag=${@:$OPTIND+1:1}
configName=${@:$OPTIND+2:1}
[[ ! $configName =~ ".config" ]] && usage "please specify a .config file!"
cfg=$ROOTCOREBIN/data/HGamTools/$configName
echo "sample:             $sample"
echo "htag:               $htag"
echo "config:             $cfg"
echo "download directory: $downloadDir"
echo "options:            ${options[@]}" 


[[ ! -e $cfg ]] && usage "Cannot find $configName in this location: $config"
cfgName=${configName%.*}
config=HGamTools/$configName

EOSdir=root://eosatlas.cern.ch//eos/atlas/atlascerngroupdisk/phys-higgs/HSG1/MxAOD/${htag}_stage
[[ ! "$EOS_htag" == "" ]] && EOSdir=root://eosatlas.cern.ch//eos/atlas/atlascerngroupdisk/phys-higgs/HSG1/MxAOD/${EOS_htag}_stage

EOSdirPhotonSys=$EOSdir/PhotonSys
EOSdirAllSys=$EOSdir/MxAODAllSys
EOSdirMC25ns=$EOSdir/mc_25ns
EOSdirMC50ns=$EOSdir/mc_50ns
EOSdirDATA25ns=$EOSdir/data_25ns
EOSdirDATA50ns=$EOSdir/data_50ns

if [ ! -d "$downloadDir" ]; then
  echo specified download directory $downloadDir does not exist! Please create/change.
  exit 0
fi


getOutputDSnameData() {
  ds=$(echo $dataset | cut -f2 -d:)
  ds2=$(echo $ds | awk -F '.merge' {'print $1'})
  ds3=$(echo $ds2 | awk -F '.PhysCont' {'print $1'})
  ptag=${dataset: -6}
  outputMxAOD=user.${RUCIO_ACCOUNT}.${ds3}.${cfgName}.${ptag%?}.${htag}_MxAOD.root
  [[ "$official" == "true" ]] && outputMxAOD=group.phys-higgs.${ds3}.${cfgName}.${ptag%?}.${htag}_MxAOD.root
}
getOutputDSnameMC() {
  ptag=${dataset: -6}
  outputMxAOD=user.${RUCIO_ACCOUNT}.${sample}.${cfgName}.${ptag%?}.${htag}_MxAOD.root
  [[ "$official" == "true" ]] && outputMxAOD=group.phys-higgs.${sample}.${cfgName}.${ptag%?}.${htag}_MxAOD.root
}

notFoundDownloads=()
failedDownloads=()

RucioDownload() {
  #testExistance=$(rucio list-dids $outputMxAOD)
  NfilesGrid=$(rucio list-files $outputMxAOD |& grep "MxAOD.root" | wc -l)
  [ "$NfilesGrid" -eq "0" ] && echo "ERROR! MxAOD $outputMxAOD does not exist on grid! Check name or grid status!" && \
    notFoundDownloads+=$outputMxAOD && return 1
  echo "Starting Rucio Download of file $outputMxAOD..."
  echo
  cmd="rucio download $outputMxAOD --dir $downloadDir"
  $cmd 
  files=$(echo $downloadDir/$outputMxAOD/*)
  Nfiles=$(echo $files | awk '{print NF}')
  if [ ! "$Nfiles" -eq "$NfilesGrid" ]; then
    echo "ERROR! Dataset $outputMxAOD did not download all files! Files on Grid: $NfilesGrid, Files locally: $Nfiles!"
    failedDownloads+=$outputMxAOD
  fi
}

downloadData() {
  getOutputDSnameData
  RucioDownload
}
downloadMC() {
  getOutputDSnameMC
  RucioDownload
}

directorySetup(){
  DataDir=$downloadDir/$outputMxAOD
  [[ ! -d "$downloadDir/$outputMxAOD" ]] && echo "dataset directory does not exist! $downloadDir/$outputMxAOD Not found" && return 1
  files=$(echo $DataDir/*)
  Nfiles=$(echo $files | awk '{print NF}')
  echo $outputMxAOD
  if [[ "$official" == "true" ]] ; then
    newDSname=${outputMxAOD#group.phys-higgs.}
  else
    newDSname=${outputMxAOD#user.${RUCIO_ACCOUNT}.}
  fi
  newDSname=${newDSname%_MxAOD.root}.root  
}

mergeMxAOD() {
  echo "merging MxAOD $outputMxAOD ..."
  xAODMerge -b -s $downloadDir/$newDSname $files && echo xAODMerge success! || (\
    echo xAODMerge failed :\( Safe Merging... This may take a while. \(WHY DOES THIS HAPPEN?!\) && \
    OutputFile=$($ROOTCOREBIN/user_scripts/HGamTools/SafeMerge.sh $DataDir) && echo Safe Merge done! && cp $OutputFile $downloadDir/$newDSname)
}


mergeData() {
  getOutputDSnameData
  directorySetup || return 1
  if [[ "$Nfiles" -gt "1" ]]; then
    mergeMxAOD
  elif [[ "$Nfiles" -eq "1" ]]; then
    mv $DataDir/* ${downloadDir}/$newDSname
  else
    echo "Number of files = 0? check if MxAOD $outputMxAOD downloaded correctly" 
    return 1
  fi

}
mergeMC() {
  getOutputDSnameMC
  directorySetup
  if [[ "$Nfiles" -gt "1" ]]; then
  # special case for MxAODAllSys, they do not merge well (file size blows up)
    if [[ "$outputMxAOD" =~ "MxAODAllSys" || "$outputMxAOD" =~ "PhotonSys" ]]; then
      i=$(( 1 ))
      echo "All/PhotonSys file detected! Will only rename files"
      mkdir $downloadDir/$newDSname
      for f in $files; do
        inputNo=$(printf "%03d" $i)
        AllSysDSname=${newDSname%.root}.${inputNo}.root
        #echo "mv $f $downloadDir/$newDSname/${AllSysDSname}"
        mv $f $downloadDir/$newDSname/${AllSysDSname}
        i=$(( $i + 1 ))
      done
    else
      mergeMxAOD
    fi
  elif [[ "$Nfiles" -eq "1" ]]; then
    # no need to merge if it's 1 file
    mv $DataDir/* ${downloadDir}/$newDSname
  else
    echo "Number of files = 0? check if MxAOD $outputMxAOD downloaded correctly"
  fi
}
EOS_Copy() {
  isFolder="false"
  if [[ $sample = period* ]]; then
    getOutputDSnameData
    if [[ "$sample" =~ "_50ns" ]]; then
      EOSdir=$EOSdirDATA50ns
    else
      EOSdir=$EOSdirDATA25ns
    fi
  else
    getOutputDSnameMC
    if [[ $outputMxAOD =~ "MxAODAllSys" ]]; then
      EOSdir=$EOSdirAllSys
    elif [[ $outputMxAOD =~ "PhotonSys" ]]; then
      EOSdir=$EOSdirPhotonSys
    elif [[ "$sample" =~ "_50ns" ]]; then
      EOSdir=$EOSdirMC50ns
    else
      EOSdir=$EOSdirMC25ns
    fi
  fi
  directorySetup
  [[ ! -e $downloadDir/$newDSname ]] && echo "dataset $downloadDir/$newDSname does not exist! Check arugments?"
  [[ -z $newDSname ]] && echo "newDSname not defined! This most likey means the file does not exist. Check your filename!" && return
  [[ -d $downloadDir/$newDSname ]] && isFolder="true"

  if [[ "$isFolder" == "false"  ]]; then
    xrdcp $downloadDir/$newDSname $EOSdir/$newDSname
    #echo "xrdcp $downloadDir/$newDSname $EOSdir/$newDSname"
  else
    files=$(echo $downloadDir/$newDSname/*)
    i=$(( 1 ))
    for f in $files; do
        inputNo=$(printf "%03d" $i)
        SysDSname=${newDSname%.root}.${inputNo}.root
        xrdcp $f $EOSdir/$newDSname/${SysDSname}
        #echo "xrdcp $f $EOSdirAllSys/$newDSname/${AllSysDSname}"
        i=$(( $i + 1 ))
    done
  fi
}


list=$ROOTCOREBIN/data/HGamTools/input/mc.txt
[[ $sample = period* ]] && list=$ROOTCOREBIN/data/HGamTools/input/data.txt
if [[ $sample = periodAll25ns ]]; then
    n=$(grep -c "^period. " $list)
    [[ $n = 0 ]] && usage "No samples of type $sample in $list"
    datasets=$(grep "^period. " $list | awk '{print $2}')
    for dataset in $datasets ; do
      sample=$(grep "$dataset" $list | awk '{print $1}')
      [[ $downloadFiles == "true" ]] && downloadData
      [[ $mergeFiles == "true" ]] && mergeData
      [[ $copyToEOS == "true" ]] && EOS_Copy
    done

elif [[ $sample = period* ]] ; then
  n=$(grep -c "^$sample " $list)
  [[ $n = 0 ]] && usage "No samples of type $sample in $list"
  datasets=$(grep "^$sample " $list | awk '{print $2}')
  for dataset in $datasets ; do
    [[ $downloadFiles == "true" ]] && downloadData
    [[ $mergeFiles == "true" ]] && mergeData
    [[ $copyToEOS == "true" ]] && EOS_Copy
  done
elif [[ $sample = allMC ]] ; then
  samples=$(cat $list | grep -v ^\# | awk '{print $1}')
  for sample in $samples ; do
    n=$(grep -c "^$sample " $list)
    [[ $n -gt 1 ]] && usage "$n samples of type $sample in $list ?"
    dataset=$(grep "^$sample " $list | awk '{print $2}')
    [[ $downloadFiles == "true" ]] && downloadMC
    [[ $mergeFiles == "true" ]] && mergeMC
    [[ $copyToEOS == "true" ]] && EOS_Copy
  done
else
  n=$(grep -c "^$sample " $list)
  [[ $n = 0   ]] && usage "No samples of type $sample in $list"
  [[ $n -gt 1 ]] && usage "$n samples of type $sample in $list ?"
  dataset=$(grep "^$sample " $list | awk '{print $2}')
  [[ $downloadFiles == "true" ]] && downloadMC
  [[ $mergeFiles == "true" ]] && mergeMC 
  [[ $copyToEOS == "true" ]] && EOS_Copy
fi
if [[ $downloadFiles == "true" ]]; then
  echo
  echo The following files were not found on the grid:
  for item in ${notFoundDownloads[*]}
  do
    echo $item
  done
  echo
  echo The following files were not downloaded correctly:
  for item in ${failedDownloads[*]}
  do
    echo $item
  done
fi
