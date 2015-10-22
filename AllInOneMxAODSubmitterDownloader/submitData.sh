cDir=/home/athomps/scripts/AllInOneMxAODSubmitterDownloader
RunDir=/home/athomps/MxAOD_DATA_v69/run
SaveDir=$cDir/saveMxAODtoEOS
datasetNames=$RunDir/submittedDataDatasets.txt
cd $RunDir

#source nohupsubmitMxAOD_newData.sh

cd $cDir
./test.sh $datasetNames

cd $SaveDir

setupATLAS
localSetupRucioClients
rcSetup

source saveMxAODsToEOS.sh $datasetNames > datah008_7.out
