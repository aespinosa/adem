#!/bin/bash

# job60 factor, job600 factor, job1800 factor, dir(1/2/3/4/5)

declare -a SITEDIR
#SITEDIR=("AGLT2" "CIT_CMS_T2" "GLOW" "GLOW-CMS" "Lehigh_coral" "MIT_CMS" "NWICG_NDCCL" "NYSGRID-CCR-U2" "OSG_INSTALL_TEST_2" "OSG_LIGO_MIT" "OSG_LIGO_PSU" "Purdue-Caesar" "SMU_PHY" "SPRACE" "SWT2_CPB" "TTU-ANTAEUS" "UC_Teraport" "UCLA_Saxon_Tier3" "UTA_DPCC" "cinvestav" "Nebraska" "UFlorida-HPC" "UTA_SWT2")

SITEDIR=("AGLT2" "CIT_CMS_T2" "GLOW" "GLOW-CMS" "Lehigh_coral" "MIT_CMS" "NWICG_NDCCL" "NYSGRID-CCR-U2" "OSG_INSTALL_TEST_2" "OSG_LIGO_MIT" "OSG_LIGO_PSU" "Purdue-Caesar" "SMU_PHY" "SPRACE" "SWT2_CPB" "TTU-ANTAEUS" "UCLA_Saxon_Tier3" "UTA_DPCC" "SBGrid-Harvard-Exp" "UCSDT2" "UCSDT2-B" "SPRACE-CE" "FLTECH" "cinvestav" "Nebraska" "UFlorida-HPC" "UTA_SWT2" "UC_Teraport" "GROW-UNI-P")

declare LOCAL_DIR="/home/lixi/osg/logs"
declare RECORD_DIR="/home/lixi/osg/sitesfile/SELECT"

declare -i i

rm -rf $RECORD_DIR/$4/job.score.txt

currenttime=$(echo `date '+%x %T'` | ./iso-to-secs)
daystr=$(echo `date '+%x %T'`  | awk '{print $1}')

for ((i=0 ; i<${#SITEDIR[*]}; i++)); do
   if test -s $LOCAL_DIR/${SITEDIR[$i]}/job60.tmp && test -s $LOCAL_DIR/${SITEDIR[$i]}/job600.tmp && test -s $LOCAL_DIR/${SITEDIR[$i]}/job1800.tmp; then
      recordtime60=$(tail -n 1 $LOCAL_DIR/${SITEDIR[$i]}/waittime.60.log | awk '{print $1 " " $2}' | ./iso-to-secs)
      recordtime600=$(tail -n 1 $LOCAL_DIR/${SITEDIR[$i]}/waittime.600.log | awk '{print $1 " " $2}' | ./iso-to-secs)
      timedif60=$(echo "scale=0; $currenttime-$recordtime60" | bc)
      timedif600=$(echo "scale=0; $currenttime-$recordtime600" | bc)
      if  [ "$timedif60" -lt 3600 ] && [ "$timedif600" -lt 18000 ] ; then 
         job60=$(cat $LOCAL_DIR/${SITEDIR[$i]}/job60.tmp)
         job600=$(cat $LOCAL_DIR/${SITEDIR[$i]}/job600.tmp)
         job1800=$(cat $LOCAL_DIR/${SITEDIR[$i]}/job1800.tmp)
         all60=$(grep $daystr $LOCAL_DIR/${SITEDIR[$i]}/waittime.60.log | wc -l)
         err60=$(grep $daystr $LOCAL_DIR/${SITEDIR[$i]}/waittime.60.log | grep "error" | wc -l)
         all600=$(grep $daystr $LOCAL_DIR/${SITEDIR[$i]}/waittime.600.log | wc -l)
         err600=$(grep $daystr $LOCAL_DIR/${SITEDIR[$i]}/waittime.600.log | grep "error" | wc -l)
         all1800=$(grep $daystr $LOCAL_DIR/${SITEDIR[$i]}/waittime.1800.log | wc -l)
         err1800=$(grep $daystr $LOCAL_DIR/${SITEDIR[$i]}/waittime.1800.log | grep "error" | wc -l)
         factor=$(echo "scale=3; (($all60-$err60)+($all600-$err600)+($all1800-$err1800))/($all60+$all600+$all1800)" | bc)  
         score=$(echo "scale=3; $1*$job60+$2*$job600+$3*$job1800" | bc) 
         part=$(echo "scale=0; ($score+1)/1" | bc)
         if test $part -gt 0  ; then
           score=$(echo "scale=6; $score*($factor^20)" | bc)
           echo $score >$LOCAL_DIR/${SITEDIR[$i]}/job.score
           echo ${SITEDIR[$i]} $score >>$RECORD_DIR/$4/job.score.txt          
         else
           echo -1 >$LOCAL_DIR/${SITEDIR[$i]}/job.score
           echo ${SITEDIR[$i]} -1 >>$RECORD_DIR/$4/job.score.txt
         fi
      else
         echo -1 >$LOCAL_DIR/${SITEDIR[$i]}/job.score
         echo ${SITEDIR[$i]} -1 >>$RECORD_DIR/$4/job.score.txt
      fi
    else
      echo -1 >$LOCAL_DIR/${SITEDIR[$i]}/job.score    
      echo ${SITEDIR[$i]} -1 >>$RECORD_DIR/$4/job.score.txt
    fi
done
