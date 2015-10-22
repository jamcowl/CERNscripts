
export ATLAS_LOCAL_ROOT_BASE=/cvmfs/atlas.cern.ch/repo/ATLASLocalRootBase
source ${ATLAS_LOCAL_ROOT_BASE}/user/atlasLocalSetup.sh
localSetupPandaClient
localSetupRucioClients

# get the output of pbook show(), save to file
# can comment out to speed up code if ran once already
pbookOutputFile=out.out
#echo "show()
#quit()" | pbook > $pbookOutputFile
flag=$((0))
while [ $flag -eq 0 ]; do 
  proxyInfo=$(voms-proxy-info |& grep "Proxy not found")
  [ ! -z "$proxyInfo" ] && echo "8Twmp224tony" | voms-proxy-init -voms atlas

  pbookOutput=$(pbook <<< $'show()\nquit()\n' > $pbookOutputFile)
  #[ ! -z "$pbookOutput" ] && echo "8Twmp224tony" | voms-proxy-init -voms atlas
  flag=$((1))
  count=$((0))
  echo ====================================================
  while read p; do
      [[ $p == \#* ]] && continue
      echo $p
      #echo $output 
      #check job status using pbook out.out file 
      #jobstatus=$(grep -B 10 "\-\-outDS\=user.athompso.${p}NTUP" $pbookOutputFile | \
      jobstatus=$(grep -B 10 "\-\-outDS\=${p} " $pbookOutputFile | \
        grep "taskStatus" | awk '{print $3}')
      #echo $jobstatus
      # need to set jobstatus to something to avoid errors if dataset not found
      [ -z "$jobstatus" ] && jobstatus=UNKNOWN #&& echo "8Twmp224tony" | voms-proxy-init -voms atlas 
      #echo $jobstatus
  #    if [ $jobstatus == broken ]; then
  #        echo $p >> brokenFiles.txt
  #    fi
      echo $jobstatus
      if [ "$jobstatus" == "finished" ] || [ "$jobstatus" == "done" ] || [ "$jobstatus" == "broken" ] || [ "$jobstatus" == "failed" ]; then
        flag=$((1 & $flag))
        #echo done!
      else
        flag=$((0 & $flag))
        count=$((1 + $count))
        #echo $p not done!
        #echo status: $jobstatus
      fi
  
  
  done <$1
#echo $flag
echo $count jobs not done! Sleeping 30mins...
[ $flag -eq 0 ] && sleep 30m
done

echo Jk, All Jobs done!


#jobstatus=$(grep -B 10 "\-\-outDS=user.athompso.Sherpa_gamjet_4000_CFilterBVeto.MxAOD.p2419.h008_1" out.out | \
#  grep "taskStatus" | awk '{print $3}')
#echo $jobstatus
#if [ $jobstatus == broken ]; then
#    echo TRUEBRO
#fi



