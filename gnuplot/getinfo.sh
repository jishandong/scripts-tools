#################################################
#说明：
# 定义时间TIMES参数，表示采集的次数，
# 采集时间 = TIMES * INTERVAL
#eg:
# TIMES=180 , INTERVAL=10 采集时间就是半小时
#
#################################################
#!/bin/bash
TIMES=36
INTERVAL=2
PWD=`pwd`
TIME=`date "+%F %H:%M:%S"`
TAR=`whereis tar|awk -F ":" '{print $2}'|awk '{print $1}'`
SAR=`whereis sar|awk -F ":" '{print $2}'|awk '{print $1}'`
IOSTAT=`whereis iostat|awk -F ":" '{print $2}'|awk '{print $1}'`
# Check Moniter Tool
SysInfo(){
  echo "sysip : $SYSIP"|tee $PWD/$SYSIP/sysinfo
  echo "starttime : $TIME" |tee -a $PWD/$SYSIP/sysinfo
  /sbin/ifconfig >>$PWD/$SYSIP/sysinfo
  echo "===================================" >>$PWD/$SYSIP/sysinfo
  /usr/sbin/dmidecode >>$PWD/$SYSIP/sysinfo
  echo "===================================" >>$PWD/$SYSIP/sysinfo
  /bin/cat /proc/cpuinfo >> $PWD/$SYSIP/sysinfo
  echo "===================================" >>$PWD/$SYSIP/sysinfo
  /sbin/fdisk -l >> $PWD/$SYSIP/sysinfo
  echo "===================================" >>$PWD/$SYSIP/sysinfo
  /bin/df -Th >>$PWD/$SYSIP/sysinfo
  echo "===================================" >>$PWD/$SYSIP/sysinfo
  /usr/bin/free -m >> $PWD/$SYSIP/sysinfo
  echo "===================================" >>$PWD/$SYSIP/sysinfo 
  echo ""
}
CheckEnv(){
  PUB_IP=`/sbin/ifconfig |grep "inet addr" | awk -F: '{print $2}'| awk '{print $1}'|grep -v "172\.\|10\.\|127\.\|192\."|sed -n 1p`
  PRI_IP=`/sbin/ifconfig |grep "inet addr" | awk -F: '{print $2}'| awk '{print $1}'|grep "10\.\|127\.\|192\."|sed -n 1p`
  if [ "snda$PUB_IP" == "snda" ];then
    SYSIP=$PRI_IP
  else
    SYSIP=$PUB_IP
  fi
  if [ -d $PWD/$SYSIP ];then
    rm -rf $PWD/$SYSIP
  fi
  mkdir -p $PWD/$SYSIP
  if ! grep iostat /usr/bin/iostat ;then
  yum -y install sysstat
  fi
}
GetPerf(){
  CPUUSAGE="$PWD/$SYSIP/cpuusage.log"
  MEMUSAGE="$PWD/$SYSIP/memusage.log"
  DISKUSAGE="$PWD/$SYSIP/diskusage.log"
  NETWORK="$PWD/$SYSIP/network.log"
  $SAR -P ALL $INTERVAL $TIMES>> $CPUUSAGE &
  $IOSTAT -dkx $INTERVAL $TIMES>> $DISKUSAGE &
  $SAR -n DEV $INTERVAL $TIMES>> $NETWORK &
  $SAR -r $INTERVAL $TIMES>> $MEMUSAGE &
  for ((i=0;i<$TIMES;i++))
  do
    sleep $INTERVAL
  done
}
CheckEnv
SysInfo
GetPerf
#在同一台机器上第二次采集数据时，会删除之前采集的数据，重新采集
#采集完成之后，会生产一个以 IP.tar.gz的压缩包。将这个压缩包，放到
#分析脚本performance_analyse.sh 的同级目录。
if [ -d $PWD/$SYSIP ];then
  cd $PWD
  rm -f $SYSIP.tar.gz
  tar zcvf $SYSIP.tar.gz $SYSIP
fi
