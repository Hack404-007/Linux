#!/bin/bash
export PATH=$PATH:/sbin:/usr/sbin:/usr/local/sbin:/usr/bin:/bin:/sbin

f_add_crontab()
{
  ##add crontab
  prgname=/usr/local/monredis_auto/redis_auto.sh
  prglog=/usr/local/monredis_auto/redis_auto.log
  crontab -l > /tmp/crontab.tmp
  cronnum=`grep "${prgname}" /tmp/crontab.tmp|egrep -v "^#|^$"|wc -l`
  if [ $cronnum -gt 0 ]; then
    rm -f /tmp/crontab.tmp
    echo "/usr/local/monredis_auto/redis_auto.sh crontab is exist !"
    exit 1
  fi
  echo "" >> /tmp/crontab.tmp
  echo "# redis auto restart scripts  on `date +%F" "%T`" >>  /tmp/crontab.tmp
  echo "*/2 * * * * ${prgname} >${prglog} 2>&1" >>  /tmp/crontab.tmp
  crontab /tmp/crontab.tmp && rm -f /tmp/crontab.tmp
}

##############################main###################################
#主要功能：
#1.扫描标准目录下面的redis目录及配置文件，生成监控的redis配置文件
#2.判断是否添加crontab，如无，则增加监控到crontab中
#push用户操作
#思路：/usr/local/redis 或者子目录及配置文件相关.ls -tlh |grep -v redis-template
#命名必须符合规则,每个redis独立一个目录,配置文件带端口

#if [ "`whoami`" != "push" ]; then
#  echo "`date` 当前用户非push用户，请切换到push用户操作执行."
#  exit 1
#fi
curdir=`dirname $0`
if [ $curdir = '.' ];then
   curdir=`pwd`
fi
echo ""
mkdir -p ${curdir}/bak
confile=redis_mon.conf 

hourstr="`date +%Y%m%d%H%M`"
basedir=/usr/local/redis
if [ -f ${curdir}/${confile} ]; then
  cp ${curdir}/${confile} ${curdir}/bak/${confile}.${hourstr}
  sed -i '/redis-server/d' ${curdir}/${confile}
fi
#开始扫描增加
for dirlst in `ls ${basedir}|grep -v redis-template`
do
  redisport=`echo ${dirlst} |awk -F '-' '{print $2}'`
  redislst=${basedir}/${dirlst}
  serverbin=${redislst}/bin/redis-server
  serverconf=`ls ${redislst}/conf/*${redisport}.conf|head -1`
  #/usr/local/redis/bin/redis-server | /usr/local/redis/conf/redis-appkey-msgid.conf | redis-appkey-msgid(ouyang)     |Y|
  notebase=`basename ${serverconf}|cut -d '.' -f1`
  #echo "######3${serverbin}  ${serverconf}  ${notebase}"
  if [ -f ${serverbin} ]; then 
    binflag=1
  fi
  
  if [ -f ${serverconf} ]; then
   conflag=1
  fi

  if [ "${binflag}${conflag}" = "11" ]; then
    echo "${serverbin} | ${serverconf} | ${notebase} |Y|" >>${curdir}/${confile}
    echo "${serverbin} | ${serverconf} add conf file. `date`"
  else
   echo "#####`date`#####${serverbin} or ${serverconf} 不存在或配置错误,不增加到配置文件中."
  fi
	
done

f_add_crontab
echo "###########`date` END.#################"
