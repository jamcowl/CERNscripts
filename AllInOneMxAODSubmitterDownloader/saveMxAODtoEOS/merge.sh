#!/bin/bash
Merge()
{
  #echo Merge called
  if [[ $(xAODMerge -b -s $1 $2 $3 &>>out.out && echo true) == true ]]; then
    echo $1
  else
    rm $1
    xAODMerge -b -s $1 $3 $2 &>>out.out
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
    #echo case 1
    file1=$(RecursiveMerge "${@:1:$h1}")
    file2=$(RecursiveMerge "${@: -$h2}")
    #echo $file1
    #echo $file2
    mergedFile=${file1}.${file2}
    #mergedFile=echo ${mergedFile//[/-_]/}
    Merge $mergedFile $file1 $file2
    #echo $mergedFile
  elif [ "$Nfiles" -eq "2" ]; then
    #echo case 2
    # get file names
    file1=$1
    file2=$2
    f1N=${file1:29:2}
    #echo $f1N
    f2N=${file2:29:2} 
    #echo $f2N > out.out
    mergeFileName=merge${f1N}_${f2N}.root
    Merge $mergeFileName $file1 $file2
    #echo $mergeFileName
  else
    #echo Less than 2 arguments 
    echo ${1:2}
  fi

}

files=$(echo ./*.root)

#echo $files
RecursiveMerge $files
