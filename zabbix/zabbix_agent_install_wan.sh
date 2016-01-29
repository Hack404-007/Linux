#!/bin/bash

SERVERIP=113.31.16.198
#HOSTIP=`ifconfig  |grep "10\.10"|awk -F: '{print $2}' |awk '{ print $1}'`

ls /etc/sysconfig/network-scripts/ifcfg-eth0  >>/dev/null
if [ `echo $?` = "0" ]
then
  ETH="eth0"
else
  ETH="em1"
fi
cat /etc/redhat-release |grep 7  >>/dev/null
if [ `echo $?` = "0" ]
then
   HOSTIP=`ifconfig ${ETH} |grep netmask |awk '{ print $2}'`
else
   HOSTIP=`ifconfig ${ETH} |grep "inet addr"|awk -F: '{print $2}' |awk '{ print $1}'`
fi

if [ `echo $HOSTIP` = "" ]
then
   echo "无法获取eth0/em1外网ip,请检查网卡配置！"
   exit 1
else
   echo "内网IP：$HOSTIP ,ZABBIX服务器IP: $SERVERIP "
fi



#if [ "$HOSTIP" = "" ] 
#then
#  echo "HOSTIP is null !!! please check it!"
#fi 

wget http://113.31.16.198:8889/zabbix/zabbix_centos6.tar.gz -P /tmp
if [ $? = 0 ];then
	tar zxvf /tmp/zabbix_centos6.tar.gz -C /usr/local
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
sed -i "/^SourceIP/s/10.10.16.198/$HOSTIP/" $ZABBIXDIR/etc/zabbix_agentd.conf
sed -i "/^Server/s/127.0.0.1/$SERVERIP/" $ZABBIXDIR/etc/zabbix_agentd.conf
sed -i "/^ServerActive/s/127.0.0.1/$SERVERIP/" $ZABBIXDIR/etc/zabbix_agentd.conf
sed -i "/^Hostname/s/Zabbix server/$HOSTIP/" $ZABBIXDIR/etc/zabbix_agentd.conf



#4.startup agentd
/usr/local/zabbix/sbin/zabbix_agentd -c /usr/local/zabbix/etc/zabbix_agentd.conf

if [ $? = 0 ];then

echo "Zabbix_agentd start successful !"
else
echo "Zabbix_agentd start failed !"
fi

grep zabbix /etc/rc.local && exit 0 || echo "/usr/local/zabbix/sbin/zabbix_agentd -c /usr/local/zabbix/etc/zabbix_agentd.conf" >> /etc/rc.local

rm -f /tmp/zabbix_centos6.tar.gz
