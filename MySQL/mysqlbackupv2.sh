#!/bin/bash
#
# 此脚本用来备份MySQL
USERNAME=root
PASSWORD=123456
DATE=`date +%Y-%m-%d`
BACKDIR=/app/mysqlbackup
DATADIR=/app/mydata
MySQL=`which mysql`

[ -d ${BACKDIR} ] || mkdir -p ${BACKDIR}
[ -d ${BACKDIR}/${DATE} ] || mkdir -p ${BACKDIR}/${DATE}

DATABASES=`ls -F /app/mydata/ | egrep "/" | egrep -v "mysql|performance_schema|leerw_wx" | awk -F "/" '{print $1}'|sed -e '/^$/d'`
for i in ${DATABASES}
do
	${MySQL} -u${USERNAME} -p${PASSWORD} -e "FLUSH TABLES WITH READ LOCK;"
	cd ${DATADIR}
	tar zcvf ${BACKDIR}/${DATE}/$i.tar.gz  $i
	if [ $? -eq 0 ]; then
		echo "$i BACKUP IS OK." && sleep 10
		${MySQL} -u${USERNAME} -p${PASSWORD} -e "UNLOCK TABLES;"
		${MySQL} -u${USERNAME} -p${PASSWORD} -e "EXIT;"
	else
		echo "$i BACKUP IS FAILED."
	fi
done

exit 0

