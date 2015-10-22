#!/bin/bash

scriptName=$0

setupIssue() {
  echo
  echo "$1"
  echo
  echo "To setup do:"
  echo "  export ATLAS_LOCAL_ROOT_BASE=/cvmfs/atlas.cern.ch/repo/ATLASLocalRootBase"
  echo "  source \${ATLAS_LOCAL_ROOT_BASE}/user/atlasLocalSetup.sh"
  echo "  localSetupFAX"
  echo "  rcSetup -q"
  echo "  localSetupPandaClient --noAthenaCheck"
  exit 1
}

usage() {
  printf "\n%s\n" "$1"
  printf "\nUsage:\n   %s INPUT HTAG CONFIGFILE\n" "$scriptName"
  printf "\nExample:\n  %s periodA h003 MxAOD.config\n" "$scriptName"
  printf "\nCONFIGS, see HGamTools/data/  examples:\n  MxAOD.config, MxAODAllSys.config\n"
  printf "\nINPUT, see HGamTools/data/input/  examples:\n  periodC, allMC, PowhegPy8_ggH125, PowhegPy8_VBF145 ...\n\n"
  exit 1
}

# need to define $config, $sample, $dataset and $outputDS before
submit() {
  
  [[ $sample =~ _50ns ]] && otherargs="Is50ns: YES"
  [[ "$dataset" =~ _a[0-9][0-9][0-9]_a[0-9][0-9][0-9] ]] && otherargs+=" IsAFII: YES"
  cmd="runHGamCutflowAndMxAOD $config SampleName: $sample GridDS: $dataset OutputDS: $outputDS $otherargs"
  echo
  # printing the command to the screen, can remove echo to do actual submission
  #echo $cmd
  $cmd
}

# need to define $config, $sample, $dataset before
submitData() {
  # user.NAME.INPUTDATASET.htag   %? removes last character of input dataset /
  # cut between first ':' and first '.merge'
  ds=$(echo $dataset | cut -f2 -d:)
  ds2=$(echo $ds | awk -F '.merge' {'print $1'})
  runN=${ds2:13:8}  
  [ "$runN" -ge "00267073" ] && [ "$runN" -le "00271744" ] && export otherargs="Is50ns: YES"
  ptag=${dataset: -6}
  outputDS=user.${RUCIO_ACCOUNT}.${ds2}.${cfgName}.${ptag%?}.$htag
  echo $outputDS >> submittedDataDatasets.txt
  submit
}

# need to define $config, $sample, $dataset before
submitMC() {
  #outputDS=user.${RUCIO_ACCOUNT}.${sample}.$htag
  ptag=${dataset: -6}
  outputDS=user.${RUCIO_ACCOUNT}.${sample}.${cfgName}.${ptag%?}.$htag
  echo $outputDS >> submittedMCDatasets.txt
  submit
}


# make sure there are 3 arguments
[[ $# != 3 ]] && usage "Not enough options !"

sample=$1
htag=$2

# make sure rootCore is seutp
[[ -z $ROOTCOREBIN ]] && setupIssue "You need to setup RootCore prior to running"

# make sure rootCore is seutp
[[ -z $RUCIO_ACCOUNT ]] && setupIssue "You need to setup rucio prior to running: localSetupFAX"

cfg=$ROOTCOREBIN/data/HGamTools/$3

# make sure the config file exist
[[ ! -e $cfg ]] && usage "Cannot find $3 in this location: $config"
cfgName=${3%.*}
config=HGamTools/$3

list=$ROOTCOREBIN/data/HGamTools/input/mc.txt
[[ $sample = period* ]] && list=$ROOTCOREBIN/data/HGamTools/input/data.txt


if [[ $sample = period* ]] ; then 

    n=$(grep -c "^$sample " $list)
    [[ $n = 0 ]] && usage "No samples of type $sample in $list"

    datasets=$(grep "^$sample " $list | awk '{print $2}')
    for dataset in $datasets ; do
  rucioCheck=$(rucio list-dids ${dataset}| grep "CONTAINER" | awk '{print $2}')
  [ -z $rucioCheck ] && echo $dataset >>NotFoundDataDatasets.txt && echo "Not Found $dataset"
  [ ! -z $rucioCheck ] && submitData

	#submitData
    done

elif [[ $sample = allMC ]] ; then

    samples=$(cat $list | grep -v ^\# | awk '{print $1}')
    for sample in $samples ; do
	n=$(grep -c "^$sample " $list)
	[[ $n -gt 1 ]] && usage "$n samples of type $sample in $list ?"
	dataset=$(grep "^$sample " $list | awk '{print $2}')

  rucioCheck=$(rucio list-dids ${p}| grep ".root " | awk '{print $2}')
  [ -z $rucioCheck ] && echo $dataset >>NotFoundDatasets.txt && echo "Not Found $dataset" && continue
  submitMC
    done

else

  # MC submission
  n=$(grep -c "^$sample " $list)
  [[ $n = 0   ]] && usage "No samples of type $sample in $list"
  [[ $n -gt 1 ]] && usage "$n samples of type $sample in $list ?"
  dataset=$(grep "^$sample " $list | awk '{print $2}')
  echo $dataset
  rucioCheck=$(rucio list-dids ${dataset}| grep "CONTAINER" | awk '{print $2}')
  [ -z $rucioCheck ] && echo $dataset >>NotFoundDatasets.txt && echo "Not Found $dataset"
  [ ! -z $rucioCheck ] && submitMC

fi
