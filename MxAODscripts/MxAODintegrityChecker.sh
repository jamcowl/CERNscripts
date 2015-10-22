#!/bin/bash

EOSdir=~/eos/atlas/atlasgroupdisk/phys-higgs/HSG1/MxAOD/h009

#EOSdir=$1
#MxAODlist=$2

#for f in $EOSdir/mc_25ns/* $EOSdir/mc_50ns/* $EOSdir/data_25ns/* $EOSdir/data_50ns/*; do 
#    filename=$(basename "$f")
#    echo $filename
#    #echo root -l $f
#    #output=$(root -l $f <<< $'CollectionTree->Print()\n.q\n' |& grep "Failed to evaluate CollectionTree->Print()") 
#    output=$(root -l $f <<< $'CollectionTree->Print()\n.q\n' |& grep "error: use of undeclared identifier") 
#    #echo $output
#    [ ! -z "$output" ] && echo $filename
#done

for f in $EOSdir/* ; do 
    filename=$(basename "$f")
    #echo $filename
    #echo root -l $f
    #output=$(root -l $f <<< $'CollectionTree->Print()\n.q\n' |& grep "Failed to evaluate CollectionTree->Print()") 
    output=$(root -l $f <<< $'CollectionTree->Print()\n.q\n' |& grep "error: use of undeclared identifier") 
    #echo $output
    [ ! -z "$output" ] && echo $filename
done
