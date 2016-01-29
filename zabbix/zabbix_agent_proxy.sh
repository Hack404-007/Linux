
#!/bin/bash

SERVERIP=gwdj.umscape.com
HOSTIP=`ifconfig |grep "106\."|awk -F: '{print $2}' |awk '{ print $1}'|head -n1`

wget http://210.14.153.155:8889/zabbix/zabbix_centos6.tar.gz -P /tmp
if [ `echo $?` = "0" ];then
     tar zxvf  /tmp/zabbix_centos6.tar.gz -C /usr/local
else
     echo " wget zabbix_centos6.tar.gz failed!"
     exit 1
fi

ZABBIXDIR=/usr/local/zabbix
#添加zabbix用户

userid=`grep zabbix /etc/passwd|wc -l`
if [ $userid = 1 ];then
echo "zabbix user exist!"
else
groupadd -g 605 zabbix
useradd -u 605 zabbix -M  -g zabbix -s /sbin/nologin
chown -R zabbix.zabbix $ZABBIXDIR
fi

#配置 zabbix_agent
sed -i "/^SourceIP/s/192.168.252.132/$HOSTIP/" $ZABBIXDIR/etc/zabbix_agentd.conf
sed -i "/^Server/s/127.0.0.1/$SERVERIP/" $ZABBIXDIR/etc/zabbix_agentd.conf
sed -i "/^ServerActive/s/127.0.0.1/$SERVERIP/" $ZABBIXDIR/etc/zabbix_agentd.conf
sed -i "/^Hostname/s/Zabbix server/$HOSTIP/" $ZABBIXDIR/etc/zabbix_agentd.conf
sed -i "/^Hostname/s/192.168.252.132/$HOSTIP/" $ZABBIXDIR/etc/zabbix_agentd.conf

#4.startup agentd

/usr/local/zabbix/sbin/zabbix_agentd -c /usr/local/zabbix/etc/zabbix_agentd.conf

if [ $? = 0 ];then

echo "Zabbix_agentd start successful !"
else
echo "Zabbix_agentd start failed !"
fi

grep zabbix /etc/rc.local && exit 0 || echo "/usr/local/zabbix/sbin/zabbix_agentd -c /usr/local/zabbix/etc/zabbix_agentd.conf" >> /etc/rc.local

rm -f /tmp/zabbix_centos6.tar.gz
