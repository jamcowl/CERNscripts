export ATLAS_LOCAL_ROOT_BASE=/cvmfs/atlas.cern.ch/repo/ATLASLocalRootBase
source ${ATLAS_LOCAL_ROOT_BASE}/user/atlasLocalSetup.sh
localSetupFAX
rcSetup -q
localSetupPandaClient --noAthenaCheck

while IFS='' read -r line || [[ -n "$line" ]]; do
    ../packages/RootCoreBin/user_scripts/HGamTools/submitMxAOD.sh $line h008 MxAOD.config
done < "$1"


../packages/RootCoreBin/user_scripts/HGamTools/submitMxAOD.sh data h008_test MxAOD.config
../packages/RootCoreBin/user_scripts/HGamTools/submitMxAOD.sh allMC h008_test MxAOD.config

../packages/RootCoreBin/user_scripts/HGamTools/submitMxAOD.sh dataPeriodA h008 MxAOD.config
../packages/RootCoreBin/user_scripts/HGamTools/submitMxAOD.sh dataPeriodC h008 MxAOD.config
#../packages/RootCoreBin/user_scripts/HGamTools/submitMxAOD.sh ggH125 h003 MxAOD.config
#../packages/RootCoreBin/user_scripts/HGamTools/submitMxAOD.sh VBF125 h003 MxAOD.config
#../packages/RootCoreBin/user_scripts/HGamTools/submitMxAOD.sh WH125 h003 MxAOD.config
#../packages/RootCoreBin/user_scripts/HGamTools/submitMxAOD.sh ZH125 h003 MxAOD.config
#../packages/RootCoreBin/user_scripts/HGamTools/submitMxAOD.sh ttH125 h003 MxAOD.config
#../packages/RootCoreBin/user_scripts/HGamTools/submitMxAOD.sh ggH200 h003 MxAOD.config
#../packages/RootCoreBin/user_scripts/HGamTools/submitMxAOD.sh VBF200 h003 MxAOD.config
#../packages/RootCoreBin/user_scripts/HGamTools/submitMxAOD.sh ttH200 h003 MxAOD.config
