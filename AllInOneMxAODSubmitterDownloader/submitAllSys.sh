cDir=/home/athomps/scripts/AllInOneMxAODSubmitterDownloader
RunDir=/home/athomps/MxAOD_h008_MCAllSys/run
SaveDir=$cDir/saveMxAODtoEOS
datasetNames=$RunDir/submittedAllSysDatasets.txt
cd $RunDir

#source nohupsubmitMxAOD_MC.sh $RunDir/MissingDatasets.txt >  h008_6.out
#./submitMxAOD.sh allMC h008 MxAOD.config

cd $cDir
./test.sh $datasetNames

cd $SaveDir

setupATLAS
localSetupRucioClients
rcSetup

source saveMxAODsToEOS.sh $datasetNames > h008_2AllSys_Attempt2.out
