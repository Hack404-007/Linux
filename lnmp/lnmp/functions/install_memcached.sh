INSTALL_MEMCACHED()
{

cd $DEFAULT_DIR/src



tar zxvf libevent-1.4.14b-stable.tar.gz
cd libevent-1.4.14b-stable
./configure  --prefix=/usr/local/libevent
make && make install
cd ../

tar zxvf memcached-1.4.21.tar.gz
cd memcached-1.4.21
./configure  --enable-sasl--prefix=/usr/local/memcached --with-libevent=/usr/local/libevent
make && make install
cd ../

/bin/cp init/memcached_centos /etc/init.d/memcached
chmod +x  /etc/rc.d/init.d/memcached
chkconfig  --add memcached
chkconfig memcached on
service memcached start
lsof -i:11211 > /dev/null 2>&1
if [ $? -eq 0 ]; then
	echo "Memcached Install OK"
	sleep 5
else
	echo "Memcached Install Failed"
fi

tar zxvf memcache-2.2.7.tgz
cd memcache-2.2.7
$PHP_INSTALL_DIR/bin/phpize
./configure  --with-php-config=/usr/local/php/bin/php-config --enable-memcache
make && make install

if [ -f "$PHP_INSTALL_DIR/lib/php/extensions/`ls $PHP_INSTALL_DIR/lib/php/extensions | grep zts`/memcache.so" ];then
                [ -z "`cat $PHP_INSTALL_DIR/etc/php.ini | grep '^extension_dir'`" ] && sed -i "s@extension_dir = \"ext\"@extension_dir = \"ext\"\nextension_dir = \"$PHP_INSTALL_DIR/lib/php/extensions/`ls $PHP_INSTALL_DIR/lib/php/extensions | grep zts`\"@" $PHP_INSTALL_DIR/etc/php.ini
                sed -i 's@^extension_dir\(.*\)@extension_dir\1\nextension = "memcache.so"@' $PHP_INSTALL_DIR/etc/php.ini
                [ -d $NGINX_INSTALL_DIR ] && service php-fpm restart || service httpd restart
else
                echo -e "\033[31mPHP memcache module install failed, Please contact the author! \033[0m"
fi

}
