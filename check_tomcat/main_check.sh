#!/bin/bash


curdir=`dirname $0`
if [ $curdir = '.' ];then
   curdir=`pwd`
fi

cd $curdir

echo "##########START CHECK `date`######################"

CONF_FILE=${curdir}/etc/pid.conf
#####
#cat ${CONF_FILE}  |grep -v grep |grep -Ev "^$|^#" |awk -F"[ |]+"  '{print $1 ,$2,$3,$4 }'
##Tomcat_name       |basedir           |   start_script   |    logfile
#ios-server   | /opt/developer/app/ios-server/tomcat  | /opt/developer/app/ios-server/tomcat/bin/startup.sh  | /data/script/logs/ios-server.log
TOMCAT_NAMES=`cat ${CONF_FILE}  |grep -v grep |grep -Ev "^$|^#" |awk -F"[ |]+"  '{print $1}'`
BASEDIRS=`cat ${CONF_FILE}  |grep -v grep |grep -Ev "^$|^#" |awk -F"[ |]+"  '{print $2}'`
START_SCRIPTS=`cat ${CONF_FILE}  |grep -v grep |grep -Ev "^$|^#" |awk -F"[ |]+"  '{print $3}'`
LOGFILES=`cat ${CONF_FILE}  |grep -v grep |grep -Ev "^$|^#" |awk -F"[ |]+"  '{print $4}'`
EXEC_SCRIPT=${curdir}/check_tomcat_pid.sh

if [ ! -f ${EXEC_SCRIPTS} ]
then
   	echo "${EXEC_SCRIPTS} 不存在，请检查！"
	exit 1
fi



for TNAME in  ${TOMCAT_NAMES}
do 
	TOMCAT_NAME=${TNAME}
	BASEDIR=`cat ${CONF_FILE}|grep -v grep |grep -Ev "^$|^#"|grep ${TNAME} |awk -F"[ |]+"  '{print $2}'`
	START_SCRIPT=`cat ${CONF_FILE}|grep -v grep |grep -Ev "^$|^#" |grep ${TNAME} |awk -F"[ |]+"  '{print $3}'`
	LOGFILE=`cat ${CONF_FILE}|grep -v grep |grep -Ev "^$|^#"|grep ${TNAME} |awk -F"[ |]+"  '{print $4}'`
	if [ -n ${TOMCAT_NAME} ]
	then
   		name_flag=1
	fi

	if [ -d ${BASEDIR} ]
	then
   		base_flag=1
	fi

	if [ -f ${START_SCRIPT} ]
	then
   		start_flag=1
	fi

	if [ -n ${LOGFILE} ]
	then
   		log_flag=1
	fi
#echo ${EXEC_SCRIPT}  ${TOMCAT_NAME} ${BASEDIR} ${START_SCRIPT}    ${LOGFILE}    ${name_flag}${base_flag}${tart_flag}${log_flag}
        if [ "${name_flag}${base_flag}${start_flag}${log_flag}" = 1111  ]
	then
		${EXEC_SCRIPT}  ${TOMCAT_NAME} ${BASEDIR} ${START_SCRIPT}   >> ${curdir}/logs/${LOGFILE}	
	else
		echo "配置文件不正确，请检查！"
		exit 1
	fi
done


echo "##########END CHECK `date`######################"


