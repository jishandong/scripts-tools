#!/bin/bash

if [ $# -ne 1 ]
then
    echo "input round number"
    exit 1
fi

log="/home/qatest/PerformanceTest/projects/$1/scripts/log/*"
#echo $log
cat $log | grep "USETIME" > tmp
total_line_number=`cat tmp | wc -l`
#echo "Total line count:                   " $total_line_number
if [ -e without_container_run_time.log ]
then
    rm without_container_run_time.log
fi

index=1
#echo "Calculating time without container run......"

cat tmp | grep "rc write" | awk '{print $9}' > allrc

while read rc
do
    cat tmp | grep $rc > t
    watch_and_list_time=`cat t | grep "watch and list" | awk '{print $9}'`
    rc_in_smartQueue_time=`cat t | grep "rc in smartQueue" | awk '{print $9}'`
    rc_in_queue_time=`cat t | grep "rc in queue" | awk '{print $9}'`
    rc_cal_and_pod_write_time=`cat t | grep "rc cal and pod write" | awk '{print $11}'`
    calculate_schedule_time=`cat t | grep "calculate schedule" | awk '{print $8}'`
    pod_in_queue_time=`cat t | grep "pod in queue" | awk '{print $9}'`
    binding_write_time=`cat t | grep "binding write" | awk '{print $8}'`

#    echo "watch and list                     :" $watch_and_list_time
#    echo "rc in smartQueue                   :" $rc_in_smartQueue_time
#    echo "rc in queue                        :" $rc_in_queue_time
#    echo "rc cal and pod write               :" $rc_cal_and_pod_write_time
#    echo "calculate schedule                 :" $calculate_schedule_time
#    echo "pod in queue                       :" $pod_in_queue_time
#    echo "binding write                      :" $binding_write_time
    total_time=`expr $watch_and_list_time + $rc_in_smartQueue_time + $rc_in_queue_time + $rc_cal_and_pod_write_time + $calculate_schedule_time + $pod_in_queue_time + $binding_write_time`
    echo $total_time >> without_container_run_time.log
done < allrc


total_line_number=`cat without_container_run_time.log | wc -l`

index90=`echo "$total_line_number * 0.9" | bc`
index99=`echo "$total_line_number * 0.99" | bc`
#echo "Index90:    " $index90
#echo "Index99:    " $index99
index90=`echo ${index90} | cut -f1 -d"."`
index99=`echo ${index99} | cut -f1 -d"."`
#echo "Index90:    " $index90
#echo "Index99:    " $index99

max=`cat without_container_run_time.log | sort -n | tail -n 1`
avg=`cat without_container_run_time.log | awk '{s+=$1}END{print s/NR}'`
value90=`cat without_container_run_time.log | sort -n | head -n ${index90} | tail -n 1`
value99=`cat without_container_run_time.log | sort -n | head -n ${index99} | tail -n 1`

#echo "Without container run time max value: " $max
#echo "Without container run time avg value: " $avg
#echo "Without container run time 90% value: " $value90
#echo "Without container run time 99% value: " $value99

printf "%-30s %-15s %-15s %-15s %-15s\n" "without kubelet time" $max $avg $value90 $value99

rm tmp
rm allrc
rm t
rm without_container_run_time.log

