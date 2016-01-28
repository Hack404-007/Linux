#!/bin/bash
#
# Name:delete_table_2014.sh
# Description: Delete Data For 2014 And 201406 before
# Author: Gandolf.Tommy
# Version: 0.0.1
# Datatime: 2016-01-18 10:34:20
# Usage: sh delete_table_2014.sh

mysql_Exec='/data/soft/mysql-log/bin/mysql'
mysql_User='root'
mysql_Pass='mysqldb@ucpass2015'
mysql_Socekt='/tmp/mysql-log.sock'
opt_Log=$(pwd)/mysql.log

delete_table_2014()
{
	${mysql_Exec} -u${mysql_User} -p${mysql_Pass} -S ${mysql_Socekt} -A -e "USE ucpaas_statistics;SHOW TABLES LIKE 'tb_%2014%';" | grep "tb_" | grep -v "Table" > delete_table_2014.txt
	echo "删除表"
	while read tableName; do
#		echo $tableName
		${mysql_Exec} -u${mysql_User} -p${mysql_Pass} -S ${mysql_Socekt} -A -e "USE ucpaas_statistics;DROP TABLE ${tableName};"
		if [ $? -eq 0 ]; then
			echo "Drop Table $tableName  is OK.." >> $opt_Log
		else
			echo "Drop Table $tableName  is Filed." >> $opt_Log
		fi
	done < delete_table_2014.txt
}

delete_view_2014()
{
	${mysql_Exec} -u${mysql_User} -p${mysql_Pass} -S ${mysql_Socekt} -A -e "USE ucpaas_statistics;SHOW TABLES LIKE 'v_%2014%';"  | grep -v "Table" > delete_view_2014.txt

	while read viewName; do
                echo $viewName
               ${mysql_Exec} -u${mysql_User} -p${mysql_Pass} -S ${mysql_Socekt} -A -e "USE ucpaas_statistics;DROP VIEW ${viewName};"
               if [ $? -eq 0 ]; then
                       echo "Drop Table $viewName  is OK.." >> $opt_Log
               else
                       echo "Drop Table $viewName  is Filed." >> $opt_Log
               fi
        done < delete_view_2014.txt
}

delete_ulog_2015_06()
{
cat <<EOF
#####################################################################################
##			  删除2015年6月份之前的数据                                ##
#####################################################################################
##	  t_voice_quality_log_0                               sdk语音质量流水表    ##
##        t_voice_quality_log_vps_0                           vps媒体统计表        ##
##        t_voice_quality_log_cb_0                            cb媒体统计表         ##
##        t_sms_err_0                                         短信错误码表         ##
##        t_notify_err_0                                      语音通知错误码表     ##
##        t_verify_err_0                                      语音验证码错误码表   ##
##        t_voip_err_0                                        呼叫业务错误码表     ##
##        tb_ucpaas_mobile                                    手机信息表           ##
##        tb_ucpaas_concurrency                               rest,线路 并发量表   ##
##        tb_ucpaas_error_log_0                               sdk rest 错误日志表  ##
#####################################################################################
EOF
	echo "获取删除表名"
	while read line; do
		${mysql_Exec} -u${mysql_User} -p${mysql_Pass} -S ${mysql_Socekt} -A -e "USE ucpaas_statistics;SHOW TABLES LIKE '${line}2015%';" | grep -v "Table" | egrep -v "201506|201507|201508|201509|201510|201511|201512" > 201506.txt
	done < ./tables/2015.txt

	echo "开始删除表"
	while read tableName; do
		echo $tableName
		${mysql_Exec} -u${mysql_User} -p${mysql_Pass} -S ${mysql_Socekt} -A -e "USE ucpaas_statistics;DROP TABLE $tableName;"
			if [ $? -eq 0 ]; then
				echo "Drop Table $tableName is ok." >> $opt_Log
			else
				echo "Drop Table $tableName is Failed." >> $opt_Log
			fi
	done < 201506.txt
}

# 调用函数

# 删除2014年的数据
#delete_table_2014

# 删除2014年的视图数据
#delete_view_2014

# 删除2015年6月份之前的数据
#delete_ulog_2015_06
