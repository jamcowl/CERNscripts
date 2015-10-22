#!/bin/bash

# MUST MOUNT EOS FIRST: eosmount ~/eos

EOSdir=~/eos/atlas/atlasgroupdisk/phys-higgs/HSG1/MxAOD/h008
MxAODlist=~/MxAOD_h008/packages/HGamTools/data/input/mc.txt 
MxAODlist=~/MxAOD_h008/packages/HGamTools/data/input/data.txt 
MxAODlist=~/data.txt 
MxAODlist=/afs/cern.ch/user/a/athompso/temp/HGamTools/data/input/data.txt
MxAODlist=~/MxAOD_trunk/packages/HGamTools/data/input/data.txt 

[ ! -d "$EOSdir" ] && echo MUST MOUNT EOS First: eosmount ~/eos  && exit 1

#EOSdir=$1
#MxAODlist=$2

while read p; do
  sample=$(echo $p | awk '{print $2}')
#  [ "$sample" =~ \# ] && continue
  [[ $sample = \#* ]] && continue
  [ -z $sample ] && continue
  
  runN=${sample:26:8} 
  #echo $runN
  #echo $EOSdir/data15_13TeV.${runN}.*
  if [ ! -f $EOSdir/data_25ns/*.${runN}.* ] && [ ! -f $EOSdir/data_50ns/*.${runN}.* ]; then
    echo $sample Not Found!
    echo $sample >> MissingDataDatasets.txt
  fi

done <$MxAODlist
