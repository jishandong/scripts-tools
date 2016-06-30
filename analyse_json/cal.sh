#!/bin/bash

if [ $# -ne 1 ]
then
	echo "cal.sh directory"
	echo ""
	exit
fi

directory=$1
rm $directory/results_*
files=`ls $directory/`

for item in $files
do
	file=$directory/$item
	./cal_single.sh $file $directory &
done

while [ true ]
do
	finished=`ps aux | grep "cal_single.sh" | grep -v grep`
	if [ x"$finished" == "x" ]
	then
		first=`ls $directory | grep results | head -n 1`
		for key in `cat ${directory}/${first} | awk -F: '{print $1}'`
		do
			max=`cat $directory/results_* | grep $key | awk -F: 'BEGIN{max=0} {if($2>max) max=$2} END{print max}'`
			avg=`cat $directory/results_* | grep $key | awk -F: 'BEGIN{sum=0; count=0} {sum+=$2;count+=1} END{print sum/count}'`
			printf "%-60s %-20s %-20s\n" "$key" "$avg" "$max" >> $directory/results
		done
		cat $directory/results | sort > $directory/results_final
		rm $directory/results
		echo "Finished. See results in $directory/results_final"
		break
	else
		echo `date` " : Calculating......"
	fi
done
