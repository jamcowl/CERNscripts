#!/bin/bash
# Safe Merge solves the problem of when MxAODs cause xAODMerge to segfault, producing
# an output file without a collection tree.  It seems to happen sometimes when you
# try to merge a big file will a small file, and the solution is to merge the small
# file with the big file.  SafeMerge recursively tries to merge files in groups
# of twos, resulting in one fully merged file.


Merge()
{
  #echo Merge called
  if [[ $(xAODMerge -b -s $1 $2 $3 &>>MergeOutput.out && echo true) == true ]]; then
    echo $1
  else
    rm $1
    xAODMerge -b -s $1 $3 $2 &>>MergeOutput.out
    echo $1
  fi 
}

RecursiveMerge()
{
  #echo 
  Nfiles=$(echo $#)
  #echo $Nfiles
  h1=$(( $Nfiles / 2 ))
  h2=$(( $Nfiles - h1 ))
  #echo $h1
  #echo $h2
  #echo "${@:5:10}"

  #echo "${@:1:$h1}"
  #echo "${@: -$h2}"
 

  if [ "$Nfiles" -gt "2" ]; then
    file1=$(RecursiveMerge "${@:1:$h1}")
    file2=$(RecursiveMerge "${@: -$h2}")
    f1Name=$(basename "$file1")
    f2Name=$(basename "$file2")
    
    mergedFile=$dataDir/${f1Name}.${f2Name}
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
    f1N=${f1Name:27:2}
    #echo $f1N
    f2N=${f2Name:27:2} 
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
