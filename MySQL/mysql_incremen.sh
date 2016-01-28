#!/bin/bash
#
# Name:mysql_incremen.sh
# Description: incremen Backup MySQL
# Author: Gandolf.Tommy
# Version: 0.0.1
# Datatime: 2016-01-21 22:10:44
# Usage: mysql_incremen.sh

userName=root
PORT=3306
PASS=lEErW39I4HF72
Host=localhost
backup_Dir=/data/backup
data_Dir=`date +%Y-%m-%d`
mysql_Exec=/usr/local/mysql/bin/mysql
mysql_Admin=/usr/local/mysql/bin/mysqladmin
mysql_Dump=/usr/local/mysql/bin/mysqldump
mysql_Data=/app/mydata
store_Data=${backup_Dir}/increamen-${data_Dir}

[ -d ${store_Data} ] || mkdir -pv ${store_Data}

${mysql_Admin} -u${userName} -p${PASS} flush-logs
binlog_Cp=`head -n -1 ${mysql_Data}/mysql-bin.index | sed 's/.\///'`

for i in ${binlog_Cp}; do
	${mysql_Exec} -u${userName} -p${PASS} -e "\! cp -p ${mysql_Data}/$i ${store_Data};"
done

binlog_Rm=`tail -n 1 ${mysql_Data}/mysql-bin.index | sed 's/.\///'`
${mysql_Exec} -u${userName} -p${PASS} -e "PURGE BINARY LOGS TO '${binlog_Rm}';"
