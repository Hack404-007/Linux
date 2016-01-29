#!/bin/bash
interfaceList=`/sbin/ifconfig  |grep 'Link encap' |awk '{print $1}' |grep -v 'lo' |sort`
  for int in $interfaceList ; do
    localIp=$(/sbin/ifconfig $int |egrep -o 'inet addr:([[:digit:]]+\.?){4}'|awk -F':' '{print $2}')
    if echo $localIp | egrep -q -v  '^(10|192\.168|172\.(1[6-9]|2[0-9]|3[01]))\.' ;then
       HOSTIP=$localIp
        if [ "a$HOSTIP" != "a" ];then
         break
        fi
    fi
  done

#SERVERIP=zabbix.umscape.com
SERVERIP=10.10.16.198
HOSTIP=`ifconfig |grep "10.10"|awk -F: '{print $2}' |awk '{ print $1}'`
ZABBIXDIR=/usr/local/zabbix

#
wget http://10.10.16.198:8889/zabbix/zabbix_suse.tar.gz
#cd /tmp
killall zabbix_agentd
rm -rf /usr/local/zabbix/
tar zxvf zabbix_suse.tar.gz -C /usr/local

#添加zabbix用户

groupadd -g 605 zabbix
useradd -u 605 zabbix -M  -g zabbix -s /sbin/nologin
chown -R zabbix.zabbix $ZABBIXDIR

#配置 zabbix_agent
sed -i "/^Server/s/127.0.0.1/$SERVERIP/" $ZABBIXDIR/etc/zabbix_agentd.conf
sed -i "/^ServerActive/s/127.0.0.1/$SERVERIP/" $ZABBIXDIR/etc/zabbix_agentd.conf
sed -i "/^Hostname/s/Zabbix server/$HOSTIP/" $ZABBIXDIR/etc/zabbix_agentd.conf
#4.startup agentd
/usr/local/zabbix/sbin/zabbix_agentd -c /usr/local/zabbix/etc/zabbix_agentd.conf
ps aux |grep zabbix |grep -v grep  |grep -v zabbix_ovm  >>/dev/null  2>&1
if [ $? = 0 ];then
	echo "Zabbix_agentd start successful !"
else
	echo "Zabbix_agentd start failed !"
fi

grep zabbix /etc/init.d/boot.local && exit 0 || echo "/usr/local/zabbix/sbin/zabbix_agentd -c /usr/local/zabbix/etc/zabbix_agentd.conf" >> /etc/init.d/boot.local
