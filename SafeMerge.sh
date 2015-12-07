#!/bin/bash
# Safe Merge solves the problem of when MxAODs cause xAODMerge to segfault, producing
# an output file without a collection tree.  It seems to happen sometimes when you
# try to merge a big file will a small file, and the solution is to merge the small
# file with the big file.  SafeMerge recursively tries to merge files in groups
# of twos, resulting in one fully merged file.


Merge()
{
  if [[ $(xAODMerge -b -s $1 $2 $3 &>>/dev/null && echo true) == true ]]; then
    echo $1
  else
    rm $1
    xAODMerge -b -s $1 $3 $2 &>>/dev/null
    echo $1
  fi 
}

RecursiveMerge()
{
  Nfiles=$(echo $#)
  h1=$(( $Nfiles / 2 ))
  h2=$(( $Nfiles - h1 ))

  if [ "$Nfiles" -gt "2" ]; then
    file1=$(RecursiveMerge "${@:1:$h1}")
    file2=$(RecursiveMerge "${@: -$h2}")
    f1Name=$(basename "$file1")
    f2Name=$(basename "$file2")
    
    mergedFileName=${f1Name}.${f2Name}
    # need to trim file name to make sure result file is within max filename size
    mergedFileName=$(echo $mergedFileName | sed 's/_00*//g' |sed 's/MxAOD.//g' | sed 's/root.//g' | sed 's/user.${RUCIO_ACCOUNT}.//g' | sed 's/group.phys-higgs.//g' | sed 's/merge//g')
    mergedFile=$dataDir/${mergedFileName}

    #mergedFile=echo ${mergedFile//[/-_]/}
    Merge $mergedFile $file1 $file2
    #echo $mergedFile
  elif [ "$Nfiles" -eq "2" ]; then
    #echo case 2
    # get file names
    file1=$1
    file2=$2
    f1Name=$(basename "$file1")
    f2Name=$(basename "$file2")
    #f1N=${f1Name:27:2}
    f1N=${f1Name%.MxAOD*}
    f1N=${f1N#*._}
    f1N=$(echo $f1N | sed 's/^0*//')
    #echo $f1N
    #f2N=${f2Name:27:2} 
    f2N=${f2Name%.MxAOD*}
    f2N=${f2N#*._}
    f2N=$(echo $f2N | sed 's/^0*//')
    #echo $f2N > out.out
    mergeFileName=$dataDir/merge${f1N}_${f2N}.root
    Merge $mergeFileName $file1 $file2
    #echo $mergeFileName
  else
    #echo Less than 2 arguments 
    #echo ${1:2}
    echo $1
  fi

}

# input dataDir
dataDir=$1
files=$(echo $dataDir/*)
#files=$(echo ./*.root)

#echo $files
RecursiveMerge $files
