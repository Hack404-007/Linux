#!/bin/bash
#
# Name:mydumper_backup.sh
# Description: Use mydumper Backup MySQL
# Author: Gandolf.Tommy
# Version: 0.0.1
# Datatime: 2016-01-19 16:31:29
# Usage: mydumper_backup.sh

cat << EOF
+-----------------------------------------------------------------------------------------------------------------------+
|   ===============================        Welcome TO Use MydumPer Backup MySQL Data     ===========================    |
+-----------------------------------------------------------------------------------------------------------------------+
EOF


myDumper=/usr/local/bin/mydumper
myLoader=/usr/local/bin/myloader
userName=root
PORT=3306
PASS=lEErW39I4HF72
DATE=`date +%Y-%m-%d`
backDir=$(pwd)/${DATE}
dbName=(leerw zabbix)

[ -d ${backDir} ] || mkdir -pv ${backDir}


mydump_install()
{
	yum install glib2-devel mysql-devel zlib-devel pcre-devel -y
	wget https://launchpad.net/mydumper/0.9/0.9.1/+download/mydumper-0.9.1.tar.gz
	tar zxvf mydumper-0.9.1.tar.gz
	cd mydumper-0.9.1
	cmake .
	make && make install

	if [ -f "/usr/local/bin/mydumper" ]; then
		echo "Mydumper install Sucessed."
	else
		echo "Mydumper install Failed."
		kill $$
	fi
	
}

if [ ! -n "${myDumper}" -o ! -n "${myLoader}" ]; then
	echo "Mydumper is Not installed."
	echo "You Will be install Mydumper."
	sleep 3
	mydump_install
fi

for ((i=0;i<=${#dbName[@]};i++)); do
        ${myDumper} -u ${userName} -p ${PASS} -P ${PORT} -B ${dbName[i]}  -t 4  -o  ${backDir}/${dbName[i]}
        cd ${backDir}
        tar  zcvf  ${dbName[i]}_${DATE}.tar.gz ${dbName[i]} && rm -rf ${dbName[i]}
done

exit 0
