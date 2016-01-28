#!/bin/bash

#check mysql exist or not
if [ -d "/usr/local/mysql" ];then
echo "mysql has already instlled ! `date`" >> /tmp/mysql_install.log
exit 1
fi


#install environment
yum -y install gcc gcc-c++ cmake  ncurses-devel bison > /dev/null 2>&1

#add mysql user
groupadd -g 27 mysql
useradd -u 27 -g mysql -M -s /sbin/nologin mysql
#get package
#cd /opt
wget http://113.31.16.198:8889/mysql/mysql-5.6.22.tar.gz
tar zxvf mysql-5.6.22.tar.gz

#start to compile
cd mysql-5.6.22

cmake -DCMAKE_INSTALL_PREFIX=/usr/local/mysql \
-DMYSQL_UNIX_ADDR=/tmp/mysql.sock \
-DDEFAULT_CHARSET=utf8 \
-DDEFAULT_COLLATION=utf8_general_ci \
-DWITH_EXTRA_CHARSETS_STRING=all \
-DWITH_MYISAM_STORAGE_ENGINE=1 \
-DWITH_INNOBASE_STORAGE_ENGINE=1 \
-DWITH_MEMORY_STORAGE_ENGINE=1 \-DWITH_READLINE=1 \
-DENABLED_LOCAL_INFILE=1 \
-DMYSQL_DATADIR=/usr/local/mysql/data \
-DMYSQL_USER=mysql  > /tmp/mysql_cmake.log 2>&1

make -j 2 && make install > /tmp/mysql_makeinstall 2>&1

if [ `echo $?` = "0" ]
then 
	echo "mysql installed success!"
fi

######
chown -R mysql.mysql /usr/local/mysql/
cd /usr/local/mysql
cp support-files/mysql.server /etc/init.d/mysqld

##init 
/usr/local/mysql/scripts/mysql_install_db --user=mysql --basedir=/usr/local/mysql --datadir=/usr/local/mysql/data 
sed -i  "/^PATH/aPATH=\$PATH:\/usr\/local\/mysql\/bin\/" /root/.bash_profile
source /root/.bash_profile

##start
#/etc/init.d/mysqld start


echo "下载配置文件"
wget http://113.31.16.198:8889/mysql/my.cnf -P /etc/
