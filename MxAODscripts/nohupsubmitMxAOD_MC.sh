cd ../packages
export ATLAS_LOCAL_ROOT_BASE=/cvmfs/atlas.cern.ch/repo/ATLASLocalRootBase
source ${ATLAS_LOCAL_ROOT_BASE}/user/atlasLocalSetup.sh
localSetupFAX
rcSetup -q
cd ../run
localSetupPandaClient --noAthenaCheck

#../packages/RootCoreBin/user_scripts/HGamTools/submitMxAOD.sh dataPeriodA h008 MxAOD.config
#../packages/RootCoreBin/user_scripts/HGamTools/submitMxAOD.sh dataPeriodC h008 MxAOD.config
#../packages/RootCoreBin/user_scripts/HGamTools/submitMxAOD.sh dataPeriodD h008 MxAOD.config
#../packages/RootCoreBin/user_scripts/HGamTools/submitMxAOD.sh dataPeriodE h008 MxAOD.config
#../packages/RootCoreBin/user_scripts/HGamTools/submitMxAOD.sh allMC h008 MxAOD.config
#../packages/RootCoreBin/user_scripts/HGamTools/submitMxAOD.sh PowhegPy8_ggH125_small h008_test MxAOD.config

#while read p; do
#    #datasetName=${p#user.athompso.%MxAOD*}
#    #datasetName=${p#user.athompso.}
#    #datasetName=${datasetName%.MxAOD*}
#    datasetName=$p
#    ./submitMxAOD.sh $datasetName h008_7 MxAOD.config
#    #../packages/RootCoreBin/user_scripts/HGamTools/submitMxAOD.sh $datasetName h008_3 MxAOD.config
#    #echo "user.athompso.${p}.MxAOD" >> thirdRunMxAODs.txt
#
#
#    echo $datasetName
#done < "$1"


SAMPLES=(MGPy8_X275tohh_yybb MGPy8_H300_Xtohh_yybb MGPy8_X350tohh_yybb MGPy8_X325tohh_yybb MGPy8_zphxx_gg_mzp10_mx1 MGPy8_zphxx_gg_mzp200_mx1 MGPy8_zphxx_gg_mzp300_mx1 MGPy8_zphxx_gg_mzp2000_mx1 MGPy8_zphxx_gg_mzp10000_mx1 MGPy8_zphxx_gg_mzp10_mx150 MGPy8_zphxx_gg_mzp200_mx150 MGPy8_zphxx_gg_mzp295_mx150 MGPy8_zphxx_gg_mzp1000_mx1000 MGPy8_zphxx_gg_mzp1995_mx1000 MGPy8_shxx_gg_ms10_mx1 MGPy8_shxx_gg_ms200_mx1 MGPy8_shxx_gg_ms300_mx1 MGPy8_shxx_gg_ms2000_mx1 MGPy8_shxx_gg_ms10000_mx1 MGPy8_shxx_gg_ms10_mx150 MGPy8_shxx_gg_ms295_mx150 MGPy8_shxx_gg_ms1000_mx1000 MGPy8_shxx_gg_ms1995_mx1000 MGPy8_zp2hdmxx_gg_mzp600_mA300 MGPy8_zp2hdmxx_gg_mzp600_mA400 MGPy8_zp2hdmxx_gg_mzp800_mA500 MGPy8_zp2hdmxx_gg_mzp800_mA600 MGPy8_zp2hdmxx_gg_mzp1400_mA700 MGPy8_zp2hdmxx_gg_mzp1400_mA800 MGPy8_yybb MGPy8_ybbj MGPy8_yybj MGPy8_ybjj MGPy8_yjjj PowhegPy_ttbar_nonallhad_not4physics)

for i in "${SAMPLES[@]}"
do
#  ../packages/RootCoreBin/user_scripts/HGamTools/submitMxAOD.sh $i h008_1 MxAOD.config
  ./submitMxAOD.sh $i h008_9 MxAOD.config
done


