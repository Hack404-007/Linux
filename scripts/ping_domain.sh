#!/bin/bash
#
# Name:ping_domain.sh
# Description: Add Domain && Hosts record To /etc/hosts File
# Author: Gandolf.Tommy
# Version: 0.0.1
# Datatime: 2016-02-2 16:58:39
# Usage: ping_domain.sh

date_Time=`date +"%F %T"`
log_File=$(pwd)/domain.log
ping_Command=/bin/ping
host_File=/etc/hosts
dig_Command=/usr/bin/dig


while read domain; do
#	Domain_ip=`${ping_Command} -w 3 ${domain} 2>&1| /bin/grep "from" | head -1 | awk -F ":" '{print $1}' | awk '{print $4}'`
	Domain_ip=`${dig_Command} ${domain} | /bin/grep -v CNAME |  awk '$1 ~/^'${domain}'/ {print $5}'|/bin/grep "^[0-9]\{1,3\}\.\([0-9]\{1,3\}\.\)\{2\}[0-9]\{1,3\}$"|head -1`
#	/bin/echo "${domain}"
#	sleep 10
	if [ ! -n ${Domain_ip} ]; then
		/bin/echo "###############${date_Time}###############" >> ${log_File}
		/bin/echo "${domain} is unknow Host" >> ${log_File}
		/bin/echo " " >> ${log_File}
#		sleep 5
	else
		if /bin/echo ${Domain_ip} |/bin/grep "^[0-9]\{1,3\}\.\([0-9]\{1,3\}\.\)\{2\}[0-9]\{1,3\}$" &>/dev/null; then
			if ! /bin/grep ${domain} ${host_File} &> /dev/null; then
				/bin/echo "${Domain_ip}  ${domain}" >>  ${host_File}
				/bin/echo "###############${date_Time}###############" >> ${log_File}
				/bin/echo "${domain}	${Domain_ip} Add Hosts File is Sucessed" >> ${log_File}
				/bin/echo " " >> ${log_File}
			else
				old_ip=$(/bin/grep "${domain}" ${host_File} | awk '{print $1}')
				if [[ "${Domain_ip}" == "${old_ip}" ]]; then
					/bin/echo "###############${date_Time}###############" >> ${log_File}
					/bin/echo "${domain} IP record is not Update" >> ${log_File}
					/bin/echo " " >> ${log_File}
				else
					sed -i "s/^${old_ip} .*/${Domain_ip}  ${domain}/"  ${host_File}
					/bin/echo "###############${date_Time}###############" >> ${log_File}
					/bin/echo "${domain} IP record is Update" >> ${log_File}
					/bin/echo " " >> ${log_File}
				fi
			fi
		else
			/bin/echo "###############${date_Time}###############" >> ${log_File}
			/bin/echo "${domain} ${Domain_ip} is Error" >> ${log_File} 2>&1
			/bin/echo " " >> ${log_File}
		fi
		
	fi
		
done < /usr/local/monitor/nslookup_callback/domain.txt
