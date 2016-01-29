#!/bin/bash
export PATH=$PATH:/usr/local/bin:/usr/bin
##redis monitor for multi
#date : 2012-11-23
#role : monitor redis and auto restart  

f_send_mobile_msg()
{
 if [ $# -ne 1 ]; then
   echo "输入参数不对，请输入要发送的信息内容."   
 else 
   msgtime="`date +%Y%m%d' '%H:%M:%S`"
   content="${msgtime} $1"   
   if [ -z "$content" ];then
      echo "要发的短信内容为空"
      exit 1;
   fi
   telmsg="redis监控: ${content}"
   errinfostr="${telmsg}"
   eval "${SENDSTR}"
   rstcode=$?
   echo "##`date` 上报告警中心返回值 ${rstcode} ##"

 fi
}

##检测判断redis是否正常
f_check_redis()
{
 local redisip=$1
 local redisport=$2
 local rtimeout=5
 ##返回值 1 表示redis可能没有启动，2 表示redis可能启动但是服务有问题，0 表示redis服务正常
 (echo -en "PING\r\nset pivot damnit\r\nget pivot\r\n"; sleep 1) | ${binfile} ${redisip} ${redisport} -w ${rtimeout} >/tmp/redis_$redisport.log
 #CHECK_REDIS_OK_CMD = "(echo -en \"PING\r\nset pivot damnit\r\nget pivot\r\n\"; sleep 1) | ${binfile} ${redisip} ${redisport} -w ${rtimeout}" 
 redisrst=$?
 redisline=`cat /tmp/redis_$redisport.log|wc -l`
 rm -f /tmp/redis_$redisport.log
 if [ ${redisrst} -ne 0 ]; then
    echo "`date` check redis return ${redisrst}"
    return 1 
 else
   if [ ${redisline} -ne 4 ]; then
     return 2
   else
     return 0
   fi
 fi
 	
}

################################ main #################################
##获取本机IP
  ethnum=`/sbin/ifconfig|grep eth|wc -l`
  if [ ${ethnum} -gt 1 ]; then
    ip_inner=`/sbin/ifconfig eth1 2>/dev/null |grep "inet addr:"|awk -F ":" '{ print $2 }'|awk '{ print $1 }'`
  else
    ethname=`/sbin/ifconfig|grep eth|awk '{print $1}'|sed 's/^ //;s/ $//;s/[[:space:]]*//g'`
    ip_inner=`/sbin/ifconfig ${ethname} 2>/dev/null |grep "inet addr:"|awk -F ":" '{ print $2 }'|awk '{ print $1 }'`
  fi
  ip=${ip_inner}

curdir=`dirname $0`
if [ $curdir = '.' ];then
   curdir=`pwd`
fi
echo ""
echo "#########`date`  START.############"
binfile=/usr/bin/nc
conffile=${curdir}/redis_mon.conf
tmpconfile=${curdir}/redis_mon.conf.tmp
if [ ! -f ${binfile} ]; then
  msginfo="${ip}上/usr/bin/nc 文件不存在,无法检测,请联系运维安装后在运行redis监控."
  echo ${msginfo}
  f_send_mobile_msg ${msginfo}
  exit 1
fi

if [ ! -f ${conffile} ]; then
  msginfo="${ip}上${conffile} 文件不存在,无法运行redis监控."
  echo ${msginfo}
  f_send_mobile_msg ${msginfo}
  exit 1
fi

redisnum=`cat ${conffile}|grep -v "^#"|wc -l`
if [ ${redisnum} -lt 1 ]; then
  msginfo="${ip}上需要监控的redis数量为0,直接退出."
  echo ${msginfo}
  exit 0
fi
##解析
cat ${conffile} |grep -v "^#"|sed '/^$/d' > ${tmpconfile}
while read redisline
do
   ### binrun   |  conffile    |  runuser   |  aliasname | restart | others
   redisbin=`echo   ${redisline} |awk -F "|" '{print $1}'|sed 's/^ //;s/ $//;s/[[:space:]]*//g'`
   redisconf=`echo  ${redisline} |awk -F "|" '{print $2}'|sed 's/^ //;s/ $//;s/[[:space:]]*//g'`
   redisalias=`echo ${redisline} |awk -F "|" '{print $3}'|sed 's/^ //;s/ $//;s/[[:space:]]*//g'`
   redisctl=`echo   ${redisline} |awk -F "|" '{print $4}'|sed 's/^ //;s/ $//;s/[[:space:]]*//g'`
   
   if [ ! -f ${redisbin} ];then
     msginfo="${ip}上${redisbin}文件不存在,可能配置错误,无法继续操作,请检查."
     echo "`date` ${msginfo}"
     continue
   fi
   
   if [ ! -f ${redisconf} ];then
     msginfo="${ip}上${redisconf}文件不存在,可能配置错误,无法继续操作,请检查."
     echo "`date` ${msginfo}"
     continue
   fi
   ##提取端口号码
   redisport=`cat ${redisconf}|grep -v "^#"|grep -w port|awk '{print $2}'`
   if [ ! -n "`echo ${redisport}|sed -n '/^[0-9][0-9]*$/p'`" ]; then
     msginfo="${ip}上${redisconf}中提取端口号错误，无法继续，请检查."
     echo "`date` ${msginfo}"
     continue
   fi 
  f_check_redis ${ip} ${redisport}
  runflag=$?
  if [ ${runflag} -eq 1 ];then
    ##没有启动，需要手工执行启动？
     if [ ${redisctl} = "Y" ]; then
       procnum=`ps -ef |grep -w "${redisbin}"|grep -w "${redisconf}"|wc -l`
       if [ ${procnum} -gt 0 ]; then
         msginfo="${ip}:${redisport}上的${redisalias}进程存在,但服务检查不正常,手工检查."
         echo "`date` ${msginfo}"
         #f_send_mobile_msg ${msginfo}
       else
        ##############################################################################
          echo "`date +%Y%m%d' '%H:%M:%S` 启动.... cmd: ${redisbin} ${redisconf}"
          ${redisbin} ${redisconf}
          sleep 2
          f_check_redis ${ip} ${redisport}
          srst=$?
          echo "${srst}"
          if [ ${srst} -ne 0 ]; then
            msginfo="${ip}:${redisport}上的${redisalias}尝试自动启动有问题，请手工检查."
            echo "`date` ${msginfo}"
            f_send_mobile_msg ${msginfo}
          else 
            msginfo="${ip}:${redisport}上的${redisalias}尝试自动重启成功."
            echo "`date` ${msginfo}"
            f_send_mobile_msg ${msginfo} 
          fi
        ###################################################################################
       fi
     else
       msginfo="${ip}:${redisport}上的${redisalias}停止,配置为手工处理,不做尝试启动."
       echo "`date` ${msginfo}"
       f_send_mobile_msg ${msginfo}
     fi
  elif [ ${runflag} -eq 2 ];then
    ##启动，但是可能不正常
    msginfo="${ip}:${redisport}上的${redisalias}进程存在,但是服务可能不正常，请检查."
    echo "`date` ${msginfo}"
    #f_send_mobile_msg ${msginfo}
  elif [ ${runflag} -eq 0 ];then
    msginfo="${ip}:${redisport}上的${redisalias}运行正常. `date`"
    echo ${msginfo}
  else
    msginfo="${ip}:${redisport}上的${redisalias}检查状态为${runflag},未知,请手工检查."
    echo "`date` ${msginfo}"
    f_send_mobile_msg ${msginfo}
  fi   
	
done <${tmpconfile}
rm -f ${tmpconfile}
echo "####`date`  END."
