#!/bin/bash 
if [ $# -ne 1 ];then
    echo "input round number"
    exit 1
fi 
#log="/home/qatest/PerformanceTest/projects/$1/scripts/log/test.log"
log="/home/qatest/PerformanceTest/projects/$1/scripts/log/*"
echo $log
cat $log | grep USETIME > time.log
count=`cat time.log | grep "rc in queue" | awk '{print $9}' | sort -n | wc -l`

index90=`echo "$count * 0.9" | bc`
index99=`echo "$count * 0.99" | bc`

index90=`echo ${index90} |cut -f1 -d"."`
index99=`echo ${index99} |cut -f1 -d"."`

#echo "                                          " "MAX          AVG         90          99"
printf "%-30s %-15s %-15s %-15s %-15s\n" "" "==MAX==" "==AVG==" "==90==" "==99=="

MAX_watch_and_list=`cat time.log | grep "watch and list" | awk 'BEGIN{max=0} {if($9>max) max=$9} END{print max}'`
AVG_watch_and_list=`cat time.log | grep "watch and list"| awk 'BEGIN{sum=0; count=0} {sum+=$9;count+=1} END{print sum/count}'`
value90_watch_and_list=`cat time.log | grep "watch and list" | awk '{print $9}' | sort -n | head -n ${index90} | tail -n 1`
value99_watch_and_list=`cat time.log | grep "watch and list" | awk '{print $9}' | sort -n | head -n ${index99} | tail -n 1`
#echo "watch and list:                           " $MAX_watch_and_list"        " \|$AVG_watch_and_list"         "\|$value90_watch_and_list"         "\|$value99_watch_and_list
printf "%-30s %-15s %-15s %-15s %-15s\n" "watch and list" $MAX_watch_and_list $AVG_watch_and_list $value90_watch_and_list $value99_watch_and_list

MAX_rc_in_smartQueue=`cat time.log | grep "rc in smartQueue" | awk 'BEGIN{max=0} {if($9>max) max=$9} END{print max}'`
AVG_rc_in_smartQueue=`cat time.log | grep "rc in smartQueue"| awk 'BEGIN{sum=0; count=0} {sum+=$9;count+=1} END{print sum/count}'`
value90_rc_in_smartQueue=`cat time.log | grep "rc in smartQueue" | awk '{print $9}' | sort -n | head -n ${index90} | tail -n 1`
value99_rc_in_smartQueue=`cat time.log | grep "rc in smartQueue" | awk '{print $9}' | sort -n | head -n ${index99} | tail -n 1`
#echo "rc in smartQueue:                         " $MAX_rc_in_smartQueue"        " \|$AVG_rc_in_smartQueue"         "\|$value90_rc_in_smartQueue"         "\|$value99_rc_in_smartQueue
printf "%-30s %-15s %-15s %-15s %-15s\n" "rc in smartQueue" $MAX_rc_in_smartQueue $AVG_rc_in_smartQueue $value90_rc_in_smartQueue $value99_rc_in_smartQueue


MAX_rc_in_queue=`cat time.log | grep "rc in queue" | awk 'BEGIN{max=0} {if($9>max) max=$9} END{print max}'`
AVG_rc_in_queue=`cat time.log | grep "rc in queue"| awk 'BEGIN{sum=0; count=0} {sum+=$9;count+=1} END{print sum/count}'`
value90_rc_in_queue=`cat time.log | grep "rc in queue" | awk '{print $9}' | sort -n | head -n ${index90} | tail -n 1`
value99_rc_in_queue=`cat time.log | grep "rc in queue" | awk '{print $9}' | sort -n | head -n ${index99} | tail -n 1`
#echo "rc in work queue:                         " $MAX_rc_in_queue"         "\|$AVG_rc_in_queue"        " \|$value90_rc_in_queue"         "\|$value99_rc_in_queue
printf "%-30s %-15s %-15s %-15s %-15s\n" "rc in work queue" $MAX_rc_in_queue $AVG_rc_in_queue $value90_rc_in_queue $value99_rc_in_queue


MAX_rc_cal_and_pod_write=`cat time.log | grep "rc cal and pod write" | awk 'BEGIN{max=0} {if($11>max) max=$11} END{print max}'`
AVG_rc_cal_and_pod_write=`cat time.log | grep "rc cal and pod write"| awk 'BEGIN{sum=0; count=0} {sum+=$11;count+=1} END{print sum/count}'`
value90_rc_cal_and_pod_write=`cat time.log | grep "rc cal and pod write" | awk '{print $11}' | sort -n | head -n ${index90} | tail -n 1`
value99_rc_cal_and_pod_write=`cat time.log | grep "rc cal and pod write" | awk '{print $11}' | sort -n | head -n ${index99} | tail -n 1`
#echo "rc cal and pod write:                     " $MAX_rc_cal_and_pod_write"         "\|$AVG_rc_cal_and_pod_write"         "\|$value90_rc_cal_and_pod_write"         "\|$value99_rc_cal_and_pod_write
printf "%-30s %-15s %-15s %-15s %-15s\n" "rc cal and pod write" $MAX_rc_cal_and_pod_write $AVG_rc_cal_and_pod_write $value90_rc_cal_and_pod_write $value99_rc_cal_and_pod_write

MAX_calculate_schedule=`cat time.log | grep "calculate schedule" | awk 'BEGIN{max=0} {if($8>max) max=$8} END{print max}'`
AVG_calculate_schedule=`cat time.log | grep "calculate schedule" | awk 'BEGIN{sum=0; count=0} {sum+=$8;count+=1} END{print sum/count}'`
value90_calculate_schedule=`cat time.log | grep "calculate schedule" | awk '{print $8}' | sort -n | head -n ${index90} | tail -n 1`
value99_calculate_schedule=`cat time.log | grep "calculate schedule" | awk '{print $8}' | sort -n | head -n ${index99} | tail -n 1`
#echo "calculate schedule:                       " $MAX_calculate_schedule"         "\|$AVG_calculate_schedule"         "\|$value90_calculate_schedule"         "\|$value99_calculate_schedule
printf "%-30s %-15s %-15s %-15s %-15s\n" "calculate schedule" $MAX_calculate_schedule $AVG_calculate_schedule $value90_calculate_schedule $value99_calculate_schedule

MAX_pod_in_queue=`cat time.log | grep "pod in queue" | awk 'BEGIN{max=0} {if($9>max) max=$9} END{print max}'`
AVG_pod_in_queue=`cat time.log | grep "pod in queue"| awk 'BEGIN{sum=0; count=0} {sum+=$9;count+=1} END{print sum/count}'`
value90_pod_in_queue=`cat time.log | grep "pod in queue" | awk '{print $9}' | sort -n | head -n ${index90} | tail -n 1`
value99_pod_in_queue=`cat time.log | grep "pod in queue" | awk '{print $9}' | sort -n | head -n ${index99} | tail -n 1`
#echo "pod in queue:                             " $MAX_pod_in_queue"        " \|$AVG_pod_in_queue"         "\|$value90_pod_in_queue"         "\|$value99_pod_in_queue
printf "%-30s %-15s %-15s %-15s %-15s\n" "pod in queue" $MAX_pod_in_queue $AVG_pod_in_queue $value90_pod_in_queue $value99_pod_in_queue

MAX_binding_write=`cat time.log | grep "binding write" | awk 'BEGIN{max=0} {if($8>max) max=$8} END{print max}'`
AVG_binding_write=`cat time.log | grep "binding write"| awk 'BEGIN{sum=0; count=0} {sum+=$8;count+=1} END{if(count !=0) print sum/count}'`
value90_binding_write=`cat time.log | grep "binding write" | awk '{print $8}' | sort -n | head -n ${index90} | tail -n 1`
value99_binding_write=`cat time.log | grep "binding write" | awk '{print $8}' | sort -n | head -n ${index99} | tail -n 1`
#echo "binding write:                            " $MAX_binding_write"         "\|$AVG_binding_write"         "\|$value90_binding_write"         "\|$value99_binding_write
printf "%-30s %-15s %-15s %-15s %-15s\n" "binding write" $MAX_binding_write $AVG_binding_write $value90_binding_write $value99_binding_write

MAX_kubelet_time_before_running=`cat time.log | grep "kubelet_time_before_running" | awk 'BEGIN{max=0} {if($7>max) max=$7} END{print max}'`
AVG_kubelet_time_before_running=`cat time.log | grep "kubelet_time_before_running" | awk 'BEGIN{sum=0; count=0} {sum+=$7;count+=1} END{print sum/count}'`
value90_kubelet_time_before_running=`cat time.log | grep "kubelet_time_before_running" | awk '{print $7}' | sort -n | head -n ${index90} | tail -n 1`
value99_kubelet_time_before_running=`cat time.log | grep "kubelet_time_before_running" | awk '{print $7}' | sort -n | head -n ${index99} | tail -n 1`
#echo "kubelet time before running:              " $MAX_kubelet_time_before_running"         "\|$AVG_kubelet_time_before_running"         "\|$value90_kubelet_time_before_running"         "\|$value99_kubelet_time_before_running
printf "%-30s %-15s %-15s %-15s %-15s\n" "kubelet time before running" $MAX_kubelet_time_before_running $AVG_kubelet_time_before_running $value90_kubelet_time_before_running $value99_kubelet_time_before_running

MAX_container_run=`cat time.log | grep "container run" | awk 'BEGIN{max=0} {if($8>max) max=$8} END{print max}'`
AVG_container_run=`cat time.log | grep "container run"| awk 'BEGIN{sum=0; count=0} {sum+=$8;count+=1} END{if(count !=0) print sum/count}'`
value90_container_run=`cat time.log | grep "container run" | awk '{print $8}' | sort -n | head -n ${index90} | tail -n 1`
value99_container_run=`cat time.log | grep "container run" | awk '{print $8}' | sort -n | head -n ${index99} | tail -n 1`
#echo "container run:                            " $MAX_container_run"         "\|$AVG_container_run"         "\|$value90_container_run"         "\|$value99_container_run
printf "%-30s %-15s %-15s %-15s %-15s\n" "container run" $MAX_container_run $AVG_container_run $value90_container_run $value99_container_run

./no_container_run.sh $1

if [ -e /tmp/perf_$1 ];then
        rm -rf /tmp/perf_$1
fi

mkdir /tmp/perf_$1
dir=/tmp/perf_$1


cat $log | grep USETIME | grep "watch and list" | awk '{print $9}' > $dir/watch_and_list
cat $log | grep USETIME | grep "rc in smartQueue" | awk '{print $9}' > $dir/rc_in_smartQueue
cat $log | grep USETIME | grep "rc in queue" | awk '{print $9}' > $dir/rc_in_queue
cat $log | grep USETIME | grep "rc cal and pod write" | awk '{print $11}' > $dir/rc_cal_and_pod_write
cat $log | grep USETIME | grep "calculate schedule" | awk '{print $8}' > $dir/calculate_schedule
cat $log | grep USETIME | grep "pod in queue" | awk '{print $9}' > $dir/pod_in_queue
cat $log | grep USETIME | grep "binding write" | awk '{print $8}' > $dir/binding_write
cat $log | grep USETIME | grep "kubelet_time_before_running" | awk '{print $7}' > $dir/kubelet_time_before_running
cat $log | grep USETIME | grep "container run" | awk '{print $8}' > $dir/container_run

for i in `ls $dir`;do
    line=`wc -l $dir/$i | awk '{print $1}'`
    if [ $line -gt 0 ];then
        ./draw.sh $dir/$i
    fi
done

echo '====== see pictures in '/tmp/perf_$1 '============'
