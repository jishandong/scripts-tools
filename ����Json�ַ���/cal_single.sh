#!/bin/bash

if [ $# -ne 2 ]
then
	echo "$0 filename result_directory"
	exit
fi

file=$1
directory=$2
uuid=`cat /proc/sys/kernel/random/uuid | awk -F- '{print $5}'`
#生成随机码
for i in $( seq 0 1119 ) 
do
	remoteAgent=`cat $file | jq ".items[$i].remoteAgent" | tr -d '"'`
	#取出remoteAgent字段，并将“”符号去掉
	resource=`cat $file | jq ".items[$i].resource" | tr -d '"'`
	method=`cat $file | jq ".items[$i].method" | tr -d '"'`
	parallel=`cat $file | jq ".items[$i].parallel" | tr -d '"'`
	
	echo "${remoteAgent}_${resource}_${method}:${parallel}" >> $directory/results_$uuid

done
