cd ../packages
export ATLAS_LOCAL_ROOT_BASE=/cvmfs/atlas.cern.ch/repo/ATLASLocalRootBase
source ${ATLAS_LOCAL_ROOT_BASE}/user/atlasLocalSetup.sh
localSetupFAX
rcSetup -q
cd ../run
localSetupPandaClient --noAthenaCheck

./submitMxAOD.sh periodA h008_2 MxAOD.config
./submitMxAOD.sh periodC h008_2 MxAOD.config
./submitMxAOD.sh periodD h008_2 MxAOD.config
./submitMxAOD.sh periodE h008_2 MxAOD.config
#../packages/RootCoreBin/user_scripts/HGamTools/submitMxAOD.sh allMC h008 MxAOD.config
#../packages/RootCoreBin/user_scripts/HGamTools/submitMxAOD.sh PowhegPy8_ggH125_small h008_test MxAOD.config

#while read p; do
#    #datasetName=${p#user.athompso.%MxAOD*}
#    datasetName=${p#user.athompso.}
#    datasetName=${datasetName%.MxAOD*}
#    #datasetName=$p
#    ./submitMxAOD.sh $datasetName h008_3 MxAOD.config
#    #../packages/RootCoreBin/user_scripts/HGamTools/submitMxAOD.sh $datasetName h008_3 MxAOD.config
#    #echo "user.athompso.${p}.MxAOD" >> thirdRunMxAODs.txt
#
#
#    echo $datasetName
#done < "$1"




#for i in "${SAMPLES[@]}"
#do
#  ../packages/RootCoreBin/user_scripts/HGamTools/submitMxAOD.sh $i h008_1 MxAOD.config
#  echo "user.athompso.${i}.MxAOD" >> secondRunMxAODs.txt
#done


