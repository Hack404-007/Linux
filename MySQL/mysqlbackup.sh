#!/bin/bash
#
# 此脚本用来备份MySQL
USERNAME=root
PASSWORD=lEErW39I4HF72
DATE=`date +%Y-%m-%d`
BACKDIR=/app/mysqlbackup

#MySQL=`which mysql`
#MySQLDUMP=`which mysqldump`

[ -d ${BACKDIR} ] || mkdir -p ${BACKDIR}
[ -d ${BACKDIR}/${DATE} ] || mkdir -p ${BACKDIR}/${DATE}

DATABASES=`ls -F /app/mydata/ | egrep "/" | egrep -v "mysql|performance_schema|leerw_wx" | awk -F "/" '{print $1}'|sed -e '/^$/d'`
for i in ${DATABASES}
do
#echo ${DATABASES[i]}
	/usr/local/mysql/bin/mysqldump  --opt -u${USERNAME} -p${PASSWORD} $i | gzip > ${BACKDIR}/${DATE}/$i-backup-${DATE}.sql.gz
	if [ $? -eq 0 ]; then
		echo "$i BACKUP IS OK." && sleep 10
	else
		echo "$i BACKUP IS FAILED."
	fi
done

exit 0

