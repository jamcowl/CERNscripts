cd ../packages
export ATLAS_LOCAL_ROOT_BASE=/cvmfs/atlas.cern.ch/repo/ATLASLocalRootBase
source ${ATLAS_LOCAL_ROOT_BASE}/user/atlasLocalSetup.sh
localSetupFAX
rcSetup -q
cd ../run
localSetupPandaClient --noAthenaCheck

SignalSample=(PowhegPy8_ggH125_small PowhegPy8_ggH125 PowhegPy8_VBF125_small PowhegPy8_VBF125 Pythia8_WH125 Pythia8_ZH125 Pythia8_ttH125 aMCnloHwpp_ttH125 aMCnloPy8_bbH125_yb2 aMCnloPy8_bbH125_ybyt)

#./submitMxAOD.sh PowhegPy8_ggH125 h008 MxAODAllSys.config
for i in "${SignalSample[@]}"
do
   :
   # do whatever on $i
  ./submitMxAODAllSys.sh $i h008_2 MxAODAllSys.config
done


#../packages/RootCoreBin/user_scripts/HGamTools/submitMxAOD.sh dataPeriodA h008 MxAOD.config
#../packages/RootCoreBin/user_scripts/HGamTools/submitMxAOD.sh dataPeriodC h008 MxAOD.config
#../packages/RootCoreBin/user_scripts/HGamTools/submitMxAOD.sh dataPeriodD h008 MxAOD.config
#../packages/RootCoreBin/user_scripts/HGamTools/submitMxAOD.sh dataPeriodE h008 MxAOD.config
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


