cDir=/home/athomps/scripts/AllInOneMxAODSubmitterDownloader
# need to change RunDir to HGamFramework area
RunDir=/home/athomps/MxAOD_h008_MC/run
SaveDir=$cDir/saveMxAODtoEOS
datasetNames=$RunDir/submittedMCDatasets.txt
cd $RunDir

source nohupsubmitMxAOD_MC.sh #$RunDir/MissingDatasets.txt

#./submitMxAOD.sh allMC h008 MxAOD.config

cd $cDir
./test.sh $datasetNames

cd $SaveDir

setupATLAS
localSetupRucioClients
rcSetup

source saveMxAODsToEOS.sh $datasetNames > h008_8.out
