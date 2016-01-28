#!/bin/bash
# Author by: Tommy.Gandolf
#
if [ $UID !=  0 ]; then
        echo "Please run as root it"
        exit 1
fi
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin


# Default Work Driectory
DEFAULT_DIR=$(pwd)
INSTALL_LOG=$(pwd)/log
SCRIPT_DIR=/etc/init.d

# Default Install Driectory

NGINX_INSTALL_DIR=/usr/local/nginx
APACHE_INSTALL_DIR=/usr/local/apache
MYSQL_INSTALL_DIR=/usr/local/mysql
PHP_INSTALL_DIR=/usr/local/php

# MySQL Store Driectory
MYSQL_DATA=/data/mydata

# Web Site Driectory
WEB_HTDOCS=/data/wwwroot
WEB_LOGS=/data/weblogs

# Deps Packet Istall Driectory
PCRE_INSTALL_DIR=/usr/local/pcre
MEMCACHED_INSTALL_DIR=/usr/local/memcached
REDIS_INSTALL_DIR=/usr/local/redis


#Set Passwd For MySQL
DBPASSWD=123456

# Import Functions

. functions/check_system.sh
. functions/install_nginx.sh
. functions/install_apache.sh
. functions/install_php.sh
. functions/install_mysql.sh
. functions/install_memcached.sh
. functions/install_redis.sh
. functions/install_xcache.sh
#. functions/system_optimize.sh

printf "
#######################################################################
#             Welcome to install LNMP/LAMP for Centos 6.x             #
####################################################################### \n"
SERVICES=(LNMP LAMP  Nginx+PHP APACHE+PHP MySQL QUIT)
PS3="请选择:"
select CHOICE in ${SERVICES[@]}; do
        echo "你输入的是$REPLY, 选择的是:$CHOICE"
        if [ $REPLY == 1 ]; then
                echo -e  "\033[40;36;4m INSTALL --->  LNMP\033[0m"
		echo "INSTALL_LNMP"
		sleep 1
		echo -e "\033[40;36;4m At the first of Check the System....\033[0m"
		sleep 5
		CHECK_SYSTEM_OS
		INSTALL_NGINX
		INSTALL_MYSQL
		INSTALL_PHP
		read -p "Do you want to install Memcached Redis Xcache:【y/n】 "  answer
		if [[ $answer == "y" ]]; then
			INSTALL_MEMCACHED
			INSTALL_REDIS
			INSTALL_XCACHE
		else
			echo "Not Install it..."
		fi
		
        elif [ $REPLY == 2 ]; then
                echo -e "\033[40;36;4m INSTALL ---> LAMP\033[0m"
		echo "INSTALL_LAMP"
		echo -e "\033[40;36;4m At the first of Check the System....\033[0m"
                sleep 5
		CHECK_SYSTEM_OS
		INSTALL_APACHE
		INSTALL_MYSQL
		INSTALL_PHP
		read -p "Do you want to install Memcached Redis Xcache:【y/n】 "  answer
                if [[ $answer == "y" ]]; then
			INSTALL_MEMCACHED
			INSTALL_REDIS
			INSTALL_XCACHE
		else
			echo "Not Install it..."
		fi
        elif [ $REPLY == 3 ]; then
                echo -e "\033[40;36;4m INSTALL ---> Nginx + PHP\033[0m"
		echo "INSTALL_NGINX_PHP"
		echo -e "\033[40;36;4m At the first of Check the System....\033[0m"
                sleep 5
		CHECK_SYSTEM_OS
		INSTALL_NGINX
		INSTALL_PHP
		read -p "Do you want to install Memcached Redis Xcache:【y/n】 "  answer
                if [[ $answer == "y" ]]; then
			INSTALL_MEMCACHED
                	INSTALL_REDIS
                	INSTALL_XCACHE
		else
			echo "Not Install it..."
		fi
        elif [ $REPLY == 4 ]; then
                echo -e "\033[40;36;4m INSTALL ---> APACHE + PHP\033[0m"
		echo "INSTALL_APACHE_PHP"
		echo -e "\033[40;36;4m At the first of Check the System....\033[0m"
                sleep 5
		CHECK_SYSTEM_OS
		INSTALL_APACHE
		INSTALL_PHP
		read -p "Do you want to install Memcached Redis Xcache:【y/n】 "  answer
                if [[ $answer == "y" ]]; then
			INSTALL_MEMCACHED
                	INSTALL_REDIS
                	INSTALL_XCACHE
		else
			echo "Not install it..."
		fi
        elif [ $REPLY == 5 ]; then
                echo -e "\033[40;36;4m INSTALL ---> MySQL\033[0m"
		echo "INSTALL_MYSQL"
		echo -e "\033[40;36;4m At the first of Check the System....\033[0m"
                sleep 5	
		CHECK_SYSTEM_OS
		INSTALL_MYSQL
        elif [ $REPLY == 6 ]; then
                echo -e "\033[40;36;4m It'S Quiting....\033[0m"
                sleep 0.5
                break
        else
                echo -e "\033[40;31;1m 你输入的有误，请重新输入。【注意输入需要安装的服务编号】\033[0m"
        fi
done
while :; do
	read -p "Do you want to system optimize ? 【yes/no】:  " choice
        if [[ $choice ==  "yes" ||  $choice == "Y" ]]; then
		echo -e "\033[40;36;4m Satrting optimize System....\033[0m"
		sleep 5
		. functions/system_optimize.sh
                sleep 5
		break
        elif [[ $choice == "no" ||  $choice == "N" ]]; then
		echo -e "\033[40;36;4m Not optimize System....\033[0m"
		sleep 1
                break
        else
                echo "UNkonw You Choice..."
        fi

done
echo "Quiting ......"
