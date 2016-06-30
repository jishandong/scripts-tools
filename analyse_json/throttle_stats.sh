#获取api/throttle/all
#
#!/bin/bash

if [ $# -ne 3 ]
then
	echo "example : throttle_stats.sh interval counts result_directory"
	echo ""
	exit
fi

interval=$1
counts=$2
result_directory=$3

mkdir $result_directory

for i in $( seq 1 $counts )
do
	curl "localhost:8080/api/throttle/all" > ${result_directory}/stats_throttle_$i
	sleep $interval

done
