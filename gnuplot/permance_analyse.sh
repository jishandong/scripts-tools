#################################################
#
#  这个脚本的作用是处理由性能采集脚本收集到的性能数据
#然后使用gunplot生产直观的性能图。
#
#################################################
#!/bin/bash
SysInfo(){
  local file=$1
  local productname="unknow"
  local cpumodel="unknow"
  local cpucore="unknow"
  local cpumhz="unknow"
  local physical="unknow"
  local realcpucore="unknow"
  local diskpart="unknow"
  local memory="unknow"
  ipaddr=`cat $file |grep -i "net addr"|grep -v "127"`  
  productname=`cat $file |grep -i "product name"`
  cpumodel=`cat $file |grep -i "model name"|uniq -d`
  cpucore=`cat $file |grep "processor"|wc -l`
  cpumhz=`cat $file |grep -i "cpu MHz"|uniq -d`
  physical=`cat $file |grep -i "physical id"|sort -n|uniq -d|wc -l`
  realcpucore=`cat $file |grep -i "cpu cores"|uniq -d|awk -F ":" '{print $2}'`
  memory=` cat $file |grep -i -EB1 "mem:"`
  diskpart=`cat $file |grep -i "disk"|grep -E "[shv][d][a-z]"`
  echo "System Information:"|tee -a $REPORTFILE
  echo "IP address:"|tee -a $REPORTFILE
  echo -e "$ipaddr"|tee -a $REPORTFILE
  echo "$productname" |tee -a $REPORTFILE
  echo -e "\t$cpumodel" |tee -a $REPORTFILE
  echo -e "\tCPU cores\t:$cpucore"|tee -a $REPORTFILE
  echo -e "\t$cpumhz"|tee -a $REPORTFILE
  echo -e "\tPhysical cpu number:$physical"|tee -a $REPORTFILE
  echo -e "\tEach CPU real core:$realcpucore"|tee -a $REPORTFILE
  echo "$diskpart"|tee -a $REPORTFILE
  echo -e "Memory(MB):\n$memory"|tee -a $REPORTFILE
}
CpuAllUsage(){
  local file=$1
  cat $file|grep -i "all"|grep -v -i -E "average|linux|system" >$GNUPLOTFOLDER/sar_cpu.$$
  TITLE=`cat $file |sed "/^$/d"|grep -v -i "average|linux"|sed 1d|sed -n 1p`
  local SOURCE_SAR_CPU="$GNUPLOTFOLDER/sar_cpu.$$"
  local USER_UASGE=`echo $TITLE |awk '{print $3}'`
  local NICE_UASGE=`echo $TITLE |awk '{print $4}'`
  local SYSTEM_UASGE=`echo $TITLE |awk '{print $5}'`
  local IOWAIT_UASGE=`echo $TITLE |awk '{print $6}'`
  local STEAL_UASGE=`echo $TITLE |awk '{print $7}'`
  local IDLE_UASGE=`echo $TITLE |awk '{print $8}'`
  local cpuusagemax=`cat $SOURCE_SAR_CPU|awk '{print $3+$4+$5+$6+$7}'|sort -r|sed -n 1p`
  local Tmp_ylable=`echo $cpuusagemax|awk -F "." '{print $1}'`
  local ylable=`echo $Tmp_ylable+5|bc`
  local cpuusagemin=`cat $SOURCE_SAR_CPU|awk '{print $3+$4+$5+$6+$7}'|sort|sed -n 1p`
   local cpuusageavg=`awk 'BEGIN{total=0}{total+=$8}END{print 100-total/NR}' $SOURCE_SAR_CPU`
  echo "`date '+%F %H:%M:%S'`: CPU Performance analysis" |tee -a $REPORTFILE
  echo -e "\t1.System Cpu load(%) \tmax=$cpuusagemax,average=$cpuusageavg,mim=$cpuusagemin" |tee -a $REPORTFILE
/usr/local/bin/gnuplot --persist <<EOF 
set term png size 800,600
#================= Cpu usage area pic ===========
set output "TotalCpuUsage.png"
set key title "Total CPU usage(%)"
set key box 3
set key below
set xlabel "times"
set ylabel "TOTAL CPU USAGE(%)"
set style fill solid 1
set style histogram rowstacked
plot [1:][0:$ylable] '$SOURCE_SAR_CPU' using 3 with histogram lt rgb "#FFB3B3" title "$USER_UASGE",\
'' using 4 with histogram title "$NICE_UASGE",\
'' using 5 with histogram lt rgb "#B3CA7E" title "$SYSTEM_UASGE",\
'' using 6 with histogram lt rgb "#A464BF" title "$IOWAIT_UASGE",\
'' using 7 with histogram title "$STEAL_UASGE",\
'' using 8 with histogram lt rgb "#212121" title "$IDLE_UASGE",\
$cpuusagemax lt 4 lw 2 title "Max Usage ($cpuusagemax%)"
EOF
}
CpuEachCoreUsage(){
  local file=$1
  sed -i 's/PM//g' $file
  local corenu=`cat $file|grep -v -i -E "average|system|all|linux"|sed "/^$/d"|awk '{print $2}'|sort -n -r|uniq -d|sed -n 1p`
#  echo $corenu
  PLOT=""
  echo "">$GNUPLOTFOLDER/idle_sum.$$
  for (( i=0;i<=$corenu;i++ ))
  do
    cat $file |grep -v -i -E "average|system|all|linux"|sed "/^$/d"|awk "(\$2==$i){print}"|awk '{print $1 ," ",100-$8}'>$GNUPLOTFOLDER/$i.txt
    local idlesum=`awk 'BEGIN{total=0}{total+=$2}END{print total}' $GNUPLOTFOLDER/$i.txt`
    echo $i $idlesum >>$GNUPLOTFOLDER/idle_sum.$$
  done
  first_load=`cat $GNUPLOTFOLDER/idle_sum.$$|sort -n -k 2 -r|sed -n 1p|awk '{print $1}'`
  second_load=`cat $GNUPLOTFOLDER/idle_sum.$$|sort -n -k 2 -r|sed -n 2p|awk '{print $1}'`
  third_load=`cat $GNUPLOTFOLDER/idle_sum.$$|sort -n -k 2 -r|sed -n 3p|awk '{print $1}'`
  load=($first_load $second_load $third_load)
  echo -e "\t2.Each core load:"
  local cpuload=("First" "Second" "Third")
  local nu=0
  for i in ${load[@]}  
  do
    local coreloadmax=`cat $GNUPLOTFOLDER/$i.txt|sort -n -k 2 -r|sed -n 1p|awk '{print $2}'`
    local coreloadavg=`awk 'BEGIN{total=0}{total+=$2}END{print total/NR}' $GNUPLOTFOLDER/$i.txt`
    local coreloadmin=`cat $GNUPLOTFOLDER/$i.txt|sort -n -k 2|sed -n 1p|awk '{print $2}'`
      
    echo -e "\t\t\t Load ${cpuload[$nu]} core $i : max=$coreloadmax , avg=$coreloadavg , min=$coreloadmin"|tee -a $REPORTFILE
    nu=`echo $nu+1|bc`
  done 
  for ((i=0;i<=corenu;i++))
  do
    if [ $i -eq $first_load ];then
      LW=4
    elif [ $i -eq $second_load ];then
      LW=3
    elif [ $i -eq $third_load ];then
      LW=2
    else
      LW=1
    fi
    TMP1="$GNUPLOTFOLDER/$i.txt"
    TMP2="using 1:2 with l lw $LW"
    TMP3="core $i "
    PLOT="$PLOT \"$TMP1\" $TMP2 title \"$TMP3\","
      
  done
  local tmp_ylabel_range=`cat $file|grep -v -i -E "average|system|all|linux"|sed "/^$/d"|awk '{print 100-$8}'|sort -n -r|sed -n 1p|awk -F "." '{print $1}'|sed -n 1p`
  local ylabel_range=`echo $tmp_ylabel_range+5|bc`
/usr/local/bin/gnuplot --persist <<EOF
#=============== Each core usage =====================
set term png size 800,600
set output "CpuCoreIdle.png"
set key title "Each Core Usage(%)"
set key box 3
set key below
set ylabel "CPU Core Usage(%)"
set xdata time
set timefmt "%H:%M:%S"
plot [:][0:$ylabel_range] $PLOT
EOF
}
MemoryUsage(){
  local file=$1
  local title=`cat $file |sed '/^$/d'|grep -i -E -v "average|linux"|grep -i mem`
  sed -i 's/PM//g' $file
  local kbmemused=`echo $title|awk '{print $3}'` 
  local memused=`echo $title|awk '{print $4}'` 
  local kbbuffers=`echo $title|awk '{print $5}'` 
  local kbcached=`echo $title|awk '{print $6}'` 
  local kbcommit=`echo $title|awk '{print $7}'` 
  cat $file |sed '/^$/d'|grep -i -E -v "average|linux"|grep -i -v mem|awk '{print $1,$2/1024,($2+$3)/1024,$3/1024,$4,$5/1024,$6/1024}'>$GNUPLOTFOLDER/memory.$$
  SOURCE_FILE=$GNUPLOTFOLDER/memory.$$
  local memtotal=`awk 'BEGIN{total=0}{total+=$3}END{print total/NR}' $SOURCE_FILE`
  local memusedmax=`awk '{print $4}' $SOURCE_FILE|sort -n -r|sed -n 1p`
  local memusedavg=`awk 'BEGIN{total=0}{total+=$4}END{print total/NR}' $SOURCE_FILE`
  local memusedmin=`awk '{print $4}' $SOURCE_FILE|sort -n|sed -n 1p`
  local memfreemax=`awk '{print $2}' $SOURCE_FILE|sort -n -r|sed -n 1p`
  local memfreeavg=`awk 'BEGIN{total=0}{total+=$2}END{print total/NR}' $SOURCE_FILE`
  local memfreemin=`awk '{print $2}' $SOURCE_FILE|sort -n|sed -n 1p`
  local memcachemax=`awk '{print $7}' $SOURCE_FILE|sort -n -r|sed -n 1p`
  local memcacheavg=`awk 'BEGIN{total=0}{total+=$7}END{print total/NR}' $SOURCE_FILE`
  local memcachemin=`awk '{print $7}' $SOURCE_FILE|sort -n|sed -n 1p`
  local memused_cachemax=`awk '{print $4-$7}' $SOURCE_FILE|sort -n -r|sed -n 1p`
  local memused_cacheavg=`awk 'BEGIN{total=0}{total+=($4-$7)}END{print total/NR}' $SOURCE_FILE`
  local memused_cachemin=`awk '{print $4-$7}' $SOURCE_FILE|sort -n|sed -n 1p`
  local used_percent=`awk 'BEGIN{total=0}{total+=$5}END{print total/NR}' $SOURCE_FILE`
  echo "`date '+%F %H:%M:%S'`: Memory usage analysis" |tee -a $REPORTFILE
  echo -e "\t\t1.total memory: $memtotal MB"|tee -a $REPORTFILE
  echo -e "\t\t2.memory used: max=$memusedmax MB ,avg=$memusedavg MB ,min=$memusedmin MB"|tee -a $REPORTFILE
  echo -e "\t\t3.memory free: max=$memfreemax MB ,avg=$memfreeavg MB ,min=$memfreemin MB"|tee -a $REPORTFILE
  echo -e "\t\t4.memory cache: max=$memcachemax MB ,avg=$memcacheavg MB ,min=$memcachemin MB"|tee -a $REPORTFILE
  echo -e "\t\t4.memory used-cache: max=$memused_cachemax MB ,avg=$memused_cacheavg MB ,min=$memused_cachemin MB"|tee -a $REPORTFILE
/usr/local/bin/gnuplot --persist <<EOF
set term png size 800,600
set output "MemoryUsage.png"
set key title "Memory Use state"
set key box 3
set key below
set ylabel "MB"
set y2label "(%)"
set x2range [0:]
set y2range [0:100]
set xdata time
set timefmt "%H:%M:%S"
set xtics;set x2tics;set ytics ;set y2tics;
plot '$SOURCE_FILE' using 1:3 w p title "Total Memory",'' using 1:4 w p title "Used",'' using 1:7 w p title "Cached" ,\
'' using 5 with l lt rgb "red" title "memused($used_percent%)" axis x2y2
EOF
}
DiskUsage(){
  local file=$1
  cat $file |sed "/^$/d"|grep -v -i -E "device|linux"|sed 1d >$GNUPLOTFOLDER/disk.$$
  local SOURCE_FILE=$GNUPLOTFOLDER/disk.$$
  plot_readiops=""
  plot_writeiops=""
  local nu=1
  echo "`date '+%F %H:%M:%S'`: Disk Performance analysis" |tee -a $REPORTFILE
  for diskpart in `cat $file |sed '1,2d'|grep -v -i "device"|awk -F " " '{print $1}'|sort|uniq -d|sed '/^$/d'|grep -E "^[a-z][a-z][a-z]$"`
  do
    awk "(\$1==\"$diskpart\"){print}" $SOURCE_FILE >$GNUPLOTFOLDER/gnu_tmpfile.$diskpart
    plot_readiops="$plot_readiops \"$GNUPLOTFOLDER/gnu_tmpfile.$diskpart\" using 4 w l title \"$diskpart read IOPS\","
    awk "(\$1==\"$diskpart\"){print}" $SOURCE_FILE|awk 'BEGIN{total=0}{total+=$4}END{print total/NR}'>$GNUPLOTFOLDER/t.$$
    local read_avg_iops=`cat $GNUPLOTFOLDER/t.$$`
    rm -f $GNUPLOTFOLDER/t.$$
    awk "(\$1==\"$diskpart\"){print}" $SOURCE_FILE|awk '{print $4}'|sort -n|sed -n 1p>$GNUPLOTFOLDER/t.$$
    local read_min_iops=`cat $GNUPLOTFOLDER/t.$$`
    rm -f $GNUPLOTFOLDER/t.$$
    awk "(\$1==\"$diskpart\"){print}" $SOURCE_FILE|awk '{print $4}'|sort -n -r |sed -n 1p>$GNUPLOTFOLDER/t.$$
    local read_max_iops=`cat $GNUPLOTFOLDER/t.$$`
    rm -f $GNUPLOTFOLDER/t.$$
    plot_writeiops="$plot_writeiops \"$GNUPLOTFOLDER/gnu_tmpfile.$diskpart\" using 5 w l title \"$diskpart write IOPS\","
      
    awk "(\$1==\"$diskpart\"){print}" $SOURCE_FILE|awk 'BEGIN{total=0}{total+=$5}END{print total/NR}'>$GNUPLOTFOLDER/t.$$
    local write_avg_iops=`cat $GNUPLOTFOLDER/t.$$`
    rm -f $GNUPLOTFOLDER/t.$$
    awk "(\$1==\"$diskpart\"){print}" $SOURCE_FILE|awk '{print $5}'|sort -n|sed -n 1p>$GNUPLOTFOLDER/t.$$
    local write_min_iops=`cat $GNUPLOTFOLDER/t.$$`
    rm -f $GNUPLOTFOLDER/t.$$
    awk "(\$1==\"$diskpart\"){print}" $SOURCE_FILE|awk '{print $5}'|sort -n -r |sed -n 1p>$GNUPLOTFOLDER/t.$$
    local write_max_iops=`cat $GNUPLOTFOLDER/t.$$`
    rm -f $GNUPLOTFOLDER/t.$$
      
    awk "(\$1==\"$diskpart\"){print}" $SOURCE_FILE|awk 'BEGIN{total=0}{total+=$6}END{print total/NR}'>$GNUPLOTFOLDER/t.$$
    local avg_read_throughput=`cat $GNUPLOTFOLDER/t.$$`
    rm -f $GNUPLOTFOLDER/t.$$
    awk "(\$1==\"$diskpart\"){print}" $SOURCE_FILE|awk '{print $6}'|sort -n|sed -n 1p>$GNUPLOTFOLDER/t.$$
    local min_read_throughput=`cat $GNUPLOTFOLDER/t.$$`
    rm -f $GNUPLOTFOLDER/t.$$
    awk "(\$1==\"$diskpart\"){print}" $SOURCE_FILE|awk '{print $6}'|sort -n -r |sed -n 1p>$GNUPLOTFOLDER/t.$$
    local max_read_throughput=`cat $GNUPLOTFOLDER/t.$$`
    rm -f $GNUPLOTFOLDER/t.$$
    awk "(\$1==\"$diskpart\"){print}" $SOURCE_FILE|awk 'BEGIN{total=0}{total+=$7}END{print total/NR}'>$GNUPLOTFOLDER/t.$$
    local avg_write_throughput=`cat $GNUPLOTFOLDER/t.$$`
    rm -f $GNUPLOTFOLDER/t.$$
    awk "(\$1==\"$diskpart\"){print}" $SOURCE_FILE|awk '{print $7}'|sort -n|sed -n 1p>$GNUPLOTFOLDER/t.$$
    local min_write_throughput=`cat $GNUPLOTFOLDER/t.$$`
    rm -f $GNUPLOTFOLDER/t.$$
    awk "(\$1==\"$diskpart\"){print}" $SOURCE_FILE|awk '{print $7}'|sort -n -r |sed -n 1p>$GNUPLOTFOLDER/t.$$
    local max_write_throughput=`cat $GNUPLOTFOLDER/t.$$`
    rm -f $GNUPLOTFOLDER/t.$$
      
    awk "(\$1==\"$diskpart\"){print}" $SOURCE_FILE|awk 'BEGIN{total=0}{total+=$10}END{print total/NR}'>$GNUPLOTFOLDER/t.$$
    local avg_await=`cat $GNUPLOTFOLDER/t.$$`
    rm -f $GNUPLOTFOLDER/t.$$
    awk "(\$1==\"$diskpart\"){print}" $SOURCE_FILE|awk '{print $10}'|sort -n|sed -n 1p>$GNUPLOTFOLDER/t.$$
    local min_await=`cat $GNUPLOTFOLDER/t.$$`
    rm -f $GNUPLOTFOLDER/t.$$
    awk "(\$1==\"$diskpart\"){print}" $SOURCE_FILE|awk '{print $10}'|sort -n -r |sed -n 1p>$GNUPLOTFOLDER/t.$$
    local max_await=`cat $GNUPLOTFOLDER/t.$$`
    rm -f $GNUPLOTFOLDER/t.$$
      
    echo -e "\t\t$nu.$diskpart performance:"|tee -a $REPORTFILE
    echo -e "\t\t\t read iops:\t\t max=$read_max_iops ,\t avg=$read_avg_iops ,\t min=$read_min_iops"|tee -a $REPORTFILE
    echo -e "\t\t\t write iops:\t\t max=$write_max_iops ,\t avg=$write_avg_iops ,\t min=$write_min_iops"|tee -a $REPORTFILE
    echo -e "\t\t\t read data per second:\t max=$max_read_throughput KB,\t avg=$avg_read_throughput KB,\t min=$min_read_throughput KB"|tee -a $REPORTFILE
    echo -e "\t\t\t write data per second:\t max=$max_write_throughput KB,\t avg=$avg_write_throughput KB,\t min=$min_write_throughput KB"|tee -a $REPORTFILE
    echo -e "\t\t\t each io wait time:\t max=$max_await ms ,\t avg=$avg_await ms ,\t min=$min_await ms"|tee -a $REPORTFILE
  done
      
/usr/local/bin/gnuplot --persist <<EOF
set term png size 800,600
set output "DiskIOPSPerformance.png"
set key title "Disk IOPS"
set key box 3
set key below
set ylabel "IOPS"
plot $plot_readiops $plot_writeiops
EOF
}
NetworkPerformance(){
    local file=$1
    sed -i 's/PM//g' $file
    cat $file |grep -E "eth|em"|grep -v -i "average">$GNUPLOTFOLDER/network_sourcefile.txt
    local sourcefile=$GNUPLOTFOLDER/network_sourcefile.txt
    local titlerxpackage=`cat $file |grep -i "IFACE"|awk '{print $3}'|uniq -d`
    local titletxpackage=`cat $file |grep -i "IFACE"|awk '{print $4}'|uniq -d`
    local titlerxbyte=`cat $file |grep -i "IFACE"|awk '{print $5}'|uniq -d`
    local titletxbyte=`cat $file |grep -i "IFACE"|awk '{print $6}'|uniq -d`
    if [ $titlerxbyte == 'rxkB/s' ];then
      unit="KB"
    elif [ $titlerxbyte == 'rxbyt/s' ];then
      unit="byte"
    fi
    local rxpackage=''
    local txpackage=''
    local rxbyte=''
    local txbyte=''
    local nu=1
    echo "`date '+%F %H:%M:%S'`: Network Performance analysis" |tee -a $REPORTFILE
    for netcard in `cat $file |grep -E "eth|em"|grep -v -i "average"|awk '{print $2}'|sort|uniq -d`
    do
      cat $sourcefile|grep $netcard>$GNUPLOTFOLDER/gnu_network.$netcard
      rxpackage="$rxpackage \"$GNUPLOTFOLDER/gnu_network.$netcard\" using 1:3 w l title \"$netcard $titlerxpackage\","
      txpackage="$txpackage \"$GNUPLOTFOLDER/gnu_network.$netcard\" using 1:4 w l title \"$netcard $titletxpackage\","
      rxbyte="$rxbyte \"$GNUPLOTFOLDER/gnu_network.$netcard\" using 1:5 w l title \"$netcard $titlerxbyte\","
      txbyte="$txbyte \"$GNUPLOTFOLDER/gnu_network.$netcard\" using 1:6 w l title \"$netcard $titletxbyte\","
      max_rxpck=` cat $GNUPLOTFOLDER/gnu_network.$netcard|sort -n -r -k 3|sed -n 1p|awk '{print $4}'`   
      avg_rxpck=`awk 'BEGIN{total=0}{total+=$3}END{print total/NR}' $GNUPLOTFOLDER/gnu_network.$netcard`
      min_rxpck=` cat $GNUPLOTFOLDER/gnu_network.$netcard|sort -n -k 3|sed -n 1p|awk '{print $4}'`   
      max_txpck=` cat $GNUPLOTFOLDER/gnu_network.$netcard|sort -n -r -k 4|sed -n 1p|awk '{print $5}'`   
      avg_txpck=`awk 'BEGIN{total=0}{total+=$4}END{print total/NR}' $GNUPLOTFOLDER/gnu_network.$netcard`
      min_txpck=` cat $GNUPLOTFOLDER/gnu_network.$netcard|sort -n -k 4|sed -n 1p|awk '{print $5}'`   
      max_rxbyt=` cat $GNUPLOTFOLDER/gnu_network.$netcard|sort -n -r -k 5|sed -n 1p|awk '{print $6}'`   
      avg_rxbyt=`awk 'BEGIN{total=0}{total+=$5}END{print total/NR}' $GNUPLOTFOLDER/gnu_network.$netcard`
      min_rxbyt=` cat $GNUPLOTFOLDER/gnu_network.$netcard|sort -n -k 5|sed -n 1p|awk '{print $6}'`   
      max_txbyt=` cat $GNUPLOTFOLDER/gnu_network.$netcard|sort -n -r -k 6|sed -n 1p|awk '{print $7}'`   
      avg_txbyt=`awk 'BEGIN{total=0}{total+=$6}END{print total/NR}' $GNUPLOTFOLDER/gnu_network.$netcard`
      min_txbyt=` cat $GNUPLOTFOLDER/gnu_network.$netcard|sort -n -k 6|sed -n 1p|awk '{print $7}'`   
      echo -e "\t\t$nu.$netcard load:"|tee -a $REPORTFILE
      echo -e "\t\t\t rxpck/s:\t\t max=$max_rxpck ,\t avg=$avg_rxpck ,\t min=$min_rxpck"|tee -a $REPORTFILE
      echo -e "\t\t\t txpck/s:\t\t max=$max_txpck ,\t avg=$avg_txpck ,\t min=$min_txpck"|tee -a $REPORTFILE
      echo -e "\t\t\t rxbyt/s:\t max=$max_rxbyt $unit,\t avg=$avg_rxbyt $unit,\t min=$min_rxbyt $unit"|tee -a $REPORTFILE
      echo -e "\t\t\t txbyt/s:\t max=$max_txbyt $unit,\t avg=$avg_txbyt $unit,\t min=$min_txbyt $unit"|tee -a $REPORTFILE
      nu=`echo $nu+1|bc`
        
    done
/usr/local/bin/gnuplot --persist <<EOF
set term png size 800,600
set output "NetworkPackagePerformance.png"
set key title "network performance"
set key box 3
set key below
set ylabel "Package/s"
set xdata time
set timefmt "%H:%M:%S"
plot $rxpackage $txpackage 
EOF
/usr/local/bin/gnuplot --persist <<EOF
set term png size 800,600
set output "NetworkThougtputPerformance.png"
set key title "Throughput performance"
set key box 3
set key below
set ylabel "$unit"
set xdata time
set timefmt "%H:%M:%S"
plot $rxbyte $txbyte
EOF
}
#定义gnuplot的字体msttcore目录及字体，这个在压缩包里有，放到指定目录即可。
export GDFONTPATH="/usr/share/fonts/msttcore"
export GNUPLOT_DEFAULT_GDFONT="arial"
SYSINFO_FILE=sysinfo
CPU_USAGE_FILE=cpuusage.log
MEMORY_USAGE_FILE=memusage.log
DISK_USAGE_FILE=diskusage.log
NETWORK_USAGE_FILE=network.log
PWD=`pwd`
REPORTFILE=report.txt
GNUPLOTFOLDER="/tmp/gnuplotlinux"
mkdir -p $GNUPLOTFOLDER
#Time=`date '+%F %H:%M:%S'`
echo -e "\t\t\t\t\t\tSDG Aystem Analysis Report" > $REPORTFILE
SysInfo $SYSINFO_FILE
echo "" >> $REPORTFILE
CpuAllUsage $CPU_USAGE_FILE
CpuEachCoreUsage $CPU_USAGE_FILE
echo "" >> $REPORTFILE
MemoryUsage $MEMORY_USAGE_FILE
echo "" >> $REPORTFILE
DiskUsage $DISK_USAGE_FILE
echo "" >> $REPORTFILE
NetworkPerformance $NETWORK_USAGE_FILE
echo "" >> $REPORTFILE
#脚本执行完成之后，会在性能数据所在的目录中生成
#report.txt   性能报告文本
#TotalCpuUsage.png  CPU利用率图表
#CpuCoreIdle.png   每个CPU核心的Idle
#MemoryUsage.png   内存使用率
#DiskIOPSPerformance.png  磁盘IOPS性能
#NetworkPackagePerformance.png  网卡发包率性能
#NetworkThougtputPerformance.png 网卡吞吐性能
#################################################
