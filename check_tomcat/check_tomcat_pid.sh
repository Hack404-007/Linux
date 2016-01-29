#!/bin/bash
#Date:2011-10-24
#Author: Jet
#check tomcat 
###check tomcat  date
#*/5 * * * *   /data/script/check_tomcat_pid.sh   >> /data/script/logs/check_tomcat_pid.log  2>&1
#BASEDIR=/opt/developer/app/tomcat-ummarket/
#SCRIPT=bin/startup.sh
#STARTSCRIPT=${BASEDIR}/${SCRIPT}
#Tomcat=tomcat-ummarket

if [ $# -ne 3 ]; then
  echo "传递参数不足($#)，请检查."
  exit 1
fi
Tomcat=$1
BASEDIR=$2
SCRIPT=$3


T_Date=`date +"%F %T"`
pid=`ps aux |grep java | grep ${BASEDIR} |grep -v ${SCRIPT} | grep -v grep | awk '{print $2}'`
if [ -n "$pid" ]; then
	echo "${Tomcat}  alive! ${T_Date}" 
else 
	echo "${Tomcat} fail! ${T_Date}" 
#        /bin/sh ${STARTSCRIPT}
	sleep 5
	pid=`ps aux |grep java | grep ${BASEDIR} |grep -v ${SCRIPT} | grep -v grep | awk '{print $2}'`
	if [ -n "$pid" ]; then
        	echo "${Tomcat} start ! ${T_Date}" 
        else
        	echo "${Tomcat} fail! Please check it !${T_Date}" 
#        	/bin/sh ${STARTSCRIPT}
	fi
fi
