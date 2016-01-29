#/bin/bash
#install redis
#author:xiawei
#date 2014-04-06

info ()
{
        echo ---------------------------------
        echo -e "\033[31mREDIS批量部署脚本\033[0m"
        echo ---------------------------------
        echo -n "    ";echo "1:部署一台redis环境"
        echo -n "    ";echo "2:批量部署多个redis环境"
        echo -n "    ";echo "3:部署进程监控"
        echo -n "    ";echo "4:退出(q|Q|exit)"
        echo 
        echo ---------------------------------
        read -p "请选择你要进行的操作:" a

case $a in
        1)
        single_redis;;
        2)
        multi_redis;;
	3)
	monitor_redis;;
        4|q|Q|exit)
        return 0 ;;
        *)
        info;;
esac

}

check ()
{
ps aux |grep redis >  /dev/null 2>&1

if [ `echo $?` = 0 ]; then
	echo "已经有redis环境部署，请检查端口是否冲突！！！"
	info
fi

}

get_var () 
{
read -p  "Input the redis name and port(pushtask  16380)：" variables
#echo $variables
name=`echo $variables|awk '{print $1}'` 

if [  "$name" = "" ] ; then
	echo "Input error,please input again!"
	get_var
fi

port=`echo $variables|awk '{print $2}'`
if [  "$port" = "" ] ; then
        echo "Input port error,please input again!"
        get_var
fi

#echo $name and $port

}

get_multi_var () 
{
read -p  "Input the redis name and startport and endport (pushtask 16380 16385)：" multi_variables
#echo $multi_variables
name=`echo $multi_variables|awk '{print $1}'`

if [  "$name" = "" ] ; then
        echo "Input error,please input again!"
        get_multi_var
fi

start_port=`echo $multi_variables|awk '{print $2}'`
if [  "$start_port" = "" ] ; then
        echo "Input startport error,please input again!"
        get_multi_var
fi

end_port=`echo $multi_variables|awk '{print $3}'`
if [  "$end_port" = "" ] ; then
        echo "Input endport error,please input again!"
        get_multi_var
fi


#echo $name and $port

}


single_redis ()
{
get_var
echo $name and $port
/bin/ps aux | grep redis | grep ${port}  >/dev/null 2>&1
if [ `echo $?` = "0" ]; then
        echo "已经有redis环境部署，请检查端口:${port}是否冲突！！！"
        info
	exit 100
fi

#INSTALL REDIS
REDISBASE=/usr/local/redis/
echo "get the template file redis_template.tgz !!! "
wget http://113.31.16.198:8889/redis/redis_template.tgz   >/dev/null   2>&1
echo "unzip file!!!!"
tar -xvzf redis_template.tgz -C /usr/local/.    >/dev/null   2>&1

#configure  file 
cd  $REDISBASE

cp -r redis-template  redis-${port}
cd redis-${port}
mv conf/redis-template-16379.conf  conf/redis-${name}-${port}.conf
sed -i "s/16379/${port}/g" conf/redis-${name}-${port}.conf 
sed -i "s/template/${name}/g" conf/redis-${name}-${port}.conf 

#start redis
chown paas:users -R $REDISBASE 
REDISBIN=$REDISBASE/redis-${port}/bin/redis-server
REDISCONF=$REDISBASE/redis-${port}/conf/redis-${name}-${port}.conf
su - paas -c "${REDISBIN}  ${REDISCONF}"
${REDISBIN}  ${REDISCONF}
if [ `echo $?` = "0"  ] ; then 
	echo "Redis start success!!!"
fi 
}

multi_redis ()
{
echo "multi"

get_multi_var
echo $name and $start_port  and $end_port

#GET REDIS
REDISBASE=/usr/local/redis/
echo "get the template file redis_template.tgz !!! "
wget http://113.31.16.198:8889/redis/redis_template.tgz   >/dev/null   2>&1
echo "unzip file!!!!"
tar -xvzf redis_template.tgz -C /usr/local/.    >/dev/null   2>&1

for i in `seq $start_port  $end_port`
do 
	/bin/ps aux | grep redis | grep ${i}  >/dev/null 2>&1
	if [ `echo $?` = "0" ]; then
        	echo "已经有redis环境部署，请检查端口:${i}是否冲突！！！"
        	info
        	exit 200
	fi

	#configure  file 
	cd  $REDISBASE
	echo port:${i}
	cp -r redis-template  redis-${i}
	cd redis-${i}
	mv conf/redis-template-16379.conf  conf/redis-${name}-${i}.conf
	sed -i "s/16379/${i}/g" conf/redis-${name}-${i}.conf
	sed -i "s/template/${name}/g" conf/redis-${name}-${i}.conf

	#start redis
	chown paas:users -R  $REDISBASE  
	REDISBIN=$REDISBASE/redis-${i}/bin/redis-server
	REDISCONF=""
	REDISCONF=$REDISBASE/redis-${i}/conf/redis-${name}-${i}.conf
	su - paas -c "${REDISBIN}  ${REDISCONF}"
	${REDISBIN}  ${REDISCONF}
	if [ `echo $?` = "0"  ] ; then
        echo "Redis ${i} start success!!!"
fi

done

}

monitor_redis ()
{

yum install -y  nc
wget http://113.31.16.198:8889/redis/monredis_auto.tgz  -P /usr/local/

tar -xvf /usr/local/monredis_auto.tgz -C /usr/local/

sh /usr/local/monredis_auto/main_scan_redis.sh
su - paas -c "sh /usr/local/monredis_auto/main_scan_redis.sh"
}
info


