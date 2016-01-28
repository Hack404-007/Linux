INSTALL_REDIS()
{
cd $DEFAULT_DIR/src
tar xzf redis-2.2.7.tgz
cd redis-2.2.7
$PHP_INSTALL_DIR/bin/phpize
./configure --with-php-config=$PHP_INSTALL_DIR/bin/php-config
make && make install
cd ..
/bin/rm -rf redis-2.2.7
if [ -f "$PHP_INSTALL_DIR/lib/php/extensions/`ls $PHP_INSTALL_DIR/lib/php/extensions | grep zts`/redis.so" ];then
	[ -z "`cat $PHP_INSTALL_DIR/etc/php.ini | grep '^extension_dir'`" ] && sed -i "s@extension_dir = \"ext\"@extension_dir = \"ext\"\nextension_dir = \"$PHP_INSTALL_DIR/lib/php/extensions/`ls $PHP_INSTALL_DIR/lib/php/extensions  | grep zts`\"@" $PHP_INSTALL_DIR/etc/php.ini
	sed -i 's@^extension_dir\(.*\)@extension_dir\1\nextension = "redis.so"@' $PHP_INSTALL_DIR/etc/php.ini
	if [ -d "$NGINX_INSTALL_DIR" ]; then 
		service php-fpm restart
	else
		service httpd restart
	fi
else
	echo "Install PHP_redis is Failed..."
fi

tar xzf redis-2.8.19.tar.gz
cd redis-2.8.19
if [ `getconf WORD_BIT` == 32 ] && [ `getconf LONG_BIT` == 32 ];then
        sed -i '1i\CFLAGS= -march=i686' src/Makefile
        sed -i 's@^OPT=.*@OPT=-O2 -march=i686@' src/.make-settings
fi

make

if [ -f "src/redis-server" ];then
        mkdir -p $REDIS_INSTALL_DIR/{bin,etc,var}
        /bin/cp src/{redis-benchmark,redis-check-aof,redis-check-dump,redis-cli,redis-sentinel,redis-server} $REDIS_INSTALL_DIR/bin/
        /bin/cp redis.conf $REDIS_INSTALL_DIR/etc/
        ln -s $REDIS_INSTALL_DIR/bin/* /usr/local/bin/
        sed -i 's@pidfile.*@pidfile /var/run/redis.pid@' $REDIS_INSTALL_DIR/etc/redis.conf
        sed -i "s@logfile.*@logfile $REDIS_INSTALL_DIR/var/redis.log@" $REDIS_INSTALL_DIR/etc/redis.conf
        sed -i "s@^dir.*@dir $REDIS_INSTALL_DIR/var@" $REDIS_INSTALL_DIR/etc/redis.conf
        sed -i 's@daemonize no@daemonize yes@' $REDIS_INSTALL_DIR/etc/redis.conf
	sed -i "/# bind 127.0.0.1/s/# bind/bind/" $REDIS_INSTALL_DIR/etc/redis.conf

        Memtatol=`free -m | grep 'Mem:' | awk '{print $2}'`
        if [ $Memtatol -le 512 ]; then
                [ -z "`grep ^maxmemory $REDIS_INSTALL_DIR/etc/redis.conf`" ] && sed -i 's@maxmemory <bytes>@maxmemory <bytes>\nmaxmemory 64000000@' $REDIS_INSTALL_DIR/etc/redis.conf
        elif [ $Memtatol -gt 512 -a $Memtatol -le 1024 ]; then
                [ -z "`grep ^maxmemory $REDIS_INSTALL_DIR/etc/redis.conf`" ] && sed -i 's@maxmemory <bytes>@maxmemory <bytes>\nmaxmemory 128000000@' $REDIS_INSTALL_DIR/etc/redis.conf
        elif [ $Memtatol -gt 1024 -a $Memtatol -le 1500 ]; then
                [ -z "`grep ^maxmemory $REDIS_INSTALL_DIR/etc/redis.conf`" ] && sed -i 's@maxmemory <bytes>@maxmemory <bytes>\nmaxmemory 256000000@' $REDIS_INSTALL_DIR/etc/redis.conf
        elif [ $Memtatol -gt 1500 -a $Memtatol -le 2500 ]; then
                [ -z "`grep ^maxmemory $REDIS_INSTALL_DIR/etc/redis.conf`" ] && sed -i 's@maxmemory <bytes>@maxmemory <bytes>\nmaxmemory 360000000@' $REDIS_INSTALL_DIR/etc/redis.conf
        elif [ $Memtatol -gt 2500 -a $Memtatol -le 3500 ]; then
                [ -z "`grep ^maxmemory $REDIS_INSTALL_DIR/etc/redis.conf`" ] && sed -i 's@maxmemory <bytes>@maxmemory <bytes>\nmaxmemory 512000000@' $REDIS_INSTALL_DIR/etc/redis.conf
        elif [ $Memtatol -gt 3500 ]; then
                [ -z "`grep ^maxmemory $REDIS_INSTALL_DIR/etc/redis.conf`" ] && sed -i 's@maxmemory <bytes>@maxmemory <bytes>\nmaxmemory 1024000000@' $REDIS_INSTALL_DIR/etc/redis.conf
        fi

        cd ..
        /bin/rm -rf redis-2.8.19
        cd ..
	OS_NAME=$(cat /etc/issue  | head -n1 | awk {'print $1'})
	if [ "$OS_NAME" == "CentOS" ]; then
        	/bin/cp init/redis_centos /etc/init.d/redis-server
		chkconfig --add redis-server
		chkconfig redis-server on
	else
		/bin/cp init/redis_ubuntu /etc/init.d/redis-server
		update-rc.d redis-server defaults
	fi
	useradd -M -s /sbin/nologin redis
        chown -R redis:redis $REDIS_INSTALL_DIR/var/
        sed -i "s@/usr/local/redis@$REDIS_INSTALL_DIR@g" /etc/init.d/redis-server
        [ -z "`grep 'vm.overcommit_memory' /etc/sysctl.conf`" ] && echo 'vm.overcommit_memory = 1' >> /etc/sysctl.conf
        sysctl -p
        service redis-server start
else
	lsof -i:6379 > /dev/null && echo "Redis starting Sucessfull." || echo "Redis startting Failed.."
fi	
}
