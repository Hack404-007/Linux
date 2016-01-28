INSTALL_PHP()
{

cd $DEFAULT_DIR/src/php_deps
tar xzf libiconv-1.14.tar.gz
cd libiconv-1.14
./configure --prefix=/usr/local
make && make install
cd ../
/bin/rm -rf libiconv-1.14

tar xzf libmcrypt-2.5.8.tar.gz
cd libmcrypt-2.5.8
./configure
make && make install
ldconfig
cd libltdl/
./configure --enable-ltdl-install
make && make install
cd ../../
/bin/rm -rf libmcrypt-2.5.8

tar xzf mhash-0.9.9.9.tar.gz
cd mhash-0.9.9.9
./configure
make && make install
cd ../
/bin/rm -rf mhash-0.9.9.9
#echo "$db_install_dir/lib" > /etc/ld.so.conf.d/mysql.conf
echo '/usr/local/lib' > /etc/ld.so.conf.d/local.conf
ldconfig -v > /dev/null 2>&1
tar zxvf mcrypt-2.6.8
cd mcrypt-2.6.8
./configure
make && make install
cd ../
/bin/rm -rf mcrypt-2.6.8
cd $DEFAULT_DIR/src
tar xzf php-5.3.29.tar.gz
# useradd -M -s /sbin/nologin www
patch -d php-5.3.29 -p0 < fpm-race-condition.patch
cd php-5.3.29
if [ -d $NGINX_INSTALL_DIR ]; then
	CFLAGS= CXXFLAGS= ./configure --prefix=/usr/local/php --with-config-file-path=/usr/local/php/etc --with-fpm-user=www --with-fpm-group=www --enable-fpm --disable-fileinfo --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-iconv-dir=/usr/local --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-bcmath --enable-shmop --enable-exif --enable-sysvsem --enable-inline-optimization --with-curl --enable-mbregex --enable-mbstring --with-mcrypt --with-gd --enable-gd-native-ttf --with-openssl --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-ftp --with-gettext --enable-zip --enable-soap --disable-ipv6 --disable-debug
	make ZEND_EXTRA_LIBS='-liconv'
	make install && echo "install PHP-FPM"
	sleep 10
	# php-fpm Init Script
	/bin/cp sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm
	chmod +x /etc/init.d/php-fpm
	chkconfig --add php-fpm
	chkconfig php-fpm on

cat > $PHP_INSTALL_DIR/etc/php-fpm.conf <<EOF
;;;;;;;;;;;;;;;;;;;;;
; FPM Configuration ;
;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;
; Global Options ;
;;;;;;;;;;;;;;;;;;

[global]
pid = run/php-fpm.pid
error_log = log/php-fpm.log
log_level = warning 

emergency_restart_threshold = 30
emergency_restart_interval = 60s 
process_control_timeout = 5s
daemonize = yes

;;;;;;;;;;;;;;;;;;;;
; Pool Definitions ;
;;;;;;;;;;;;;;;;;;;;

[www]
listen = /dev/shm/php-cgi.sock
listen.backlog = 8192
listen.allowed_clients = 127.0.0.1
;listen = 127.0.0.1:9000
listen.owner = www
listen.group = www
listen.mode = 0666
user = www
group = www

pm = dynamic
pm.max_children = 12
pm.start_servers = 8
pm.min_spare_servers = 6
pm.max_spare_servers = 12
pm.max_requests = 2048
pm.process_idle_timeout = 10s
request_terminate_timeout = 120
request_slowlog_timeout = 0

slowlog = log/slow.log
rlimit_files = 51200
rlimit_core = 0

catch_workers_output = yes
env[HOSTNAME] = \$HOSTNAME
env[PATH] = /usr/local/bin:/usr/bin:/bin
env[TMP] = /tmp
env[TMPDIR] = /tmp
env[TEMP] = /tmp
EOF


	if [ $Mem -le 3000 ]; then
        	sed -i "s@^pm.max_children.*@pm.max_children = $(($Mem/2/20))@" $PHP_INSTALL_DIR/etc/php-fpm.conf
        	sed -i "s@^pm.start_servers.*@pm.start_servers = $(($Mem/2/30))@" $PHP_INSTALL_DIR/etc/php-fpm.conf
        	sed -i "s@^pm.min_spare_servers.*@pm.min_spare_servers = $(($Mem/2/40))@" $PHP_INSTALL_DIR/etc/php-fpm.conf
        	sed -i "s@^pm.max_spare_servers.*@pm.max_spare_servers = $(($Mem/2/20))@" $PHP_INSTALL_DIR/etc/php-fpm.conf
	elif [ $Mem -gt 3000 -a $Mem -le 4500 ]; then
        	sed -i "s@^pm.max_children.*@pm.max_children = 80@" $PHP_INSTALL_DIR/etc/php-fpm.conf
        	sed -i "s@^pm.start_servers.*@pm.start_servers = 50@" $PHP_INSTALL_DIR/etc/php-fpm.conf
        	sed -i "s@^pm.min_spare_servers.*@pm.min_spare_servers = 40@" $PHP_INSTALL_DIR/etc/php-fpm.conf
        	sed -i "s@^pm.max_spare_servers.*@pm.max_spare_servers = 80@" $PHP_INSTALL_DIR/etc/php-fpm.conf
	elif [ $Mem -gt 4500 -a $Mem -le 6500 ]; then
        	sed -i "s@^pm.max_children.*@pm.max_children = 90@" $PHP_INSTALL_DIR/etc/php-fpm.conf
        	sed -i "s@^pm.start_servers.*@pm.start_servers = 60@" $PHP_INSTALL_DIR/etc/php-fpm.conf
        	sed -i "s@^pm.min_spare_servers.*@pm.min_spare_servers = 50@" $PHP_INSTALL_DIR/etc/php-fpm.conf
        	sed -i "s@^pm.max_spare_servers.*@pm.max_spare_servers = 90@" $PHP_INSTALL_DIR/etc/php-fpm.conf
	elif [ $Mem -gt 6500 -a $Mem -le 8500 ]; then
        	sed -i "s@^pm.max_children.*@pm.max_children = 100@" $PHP_INSTALL_DIR/etc/php-fpm.conf
        	sed -i "s@^pm.start_servers.*@pm.start_servers = 70@" $PHP_INSTALL_DIR/etc/php-fpm.conf
        	sed -i "s@^pm.min_spare_servers.*@pm.min_spare_servers = 60@" $PHP_INSTALL_DIR/etc/php-fpm.conf
        	sed -i "s@^pm.max_spare_servers.*@pm.max_spare_servers = 100@" $PHP_INSTALL_DIR/etc/php-fpm.conf
	elif [ $Mem -gt 8500 ]; then
        	sed -i "s@^pm.max_children.*@pm.max_children = 120@" $PHP_INSTALL_DIR/etc/php-fpm.conf
        	sed -i "s@^pm.start_servers.*@pm.start_servers = 80@" $PHP_INSTALL_DIR/etc/php-fpm.conf
        	sed -i "s@^pm.min_spare_servers.*@pm.min_spare_servers = 70@" $PHP_INSTALL_DIR/etc/php-fpm.conf
        	sed -i "s@^pm.max_spare_servers.*@pm.max_spare_servers = 120@" $PHP_INSTALL_DIR/etc/php-fpm.conf
	fi
	service php-fpm start

	[ -e /dev/shm/php-cgi.sock ] && echo "PHP-FPM start OK..." || echo "PHP-FPM start Failed...."
	sleep 5
	mv $NGINX_INSTALL_DIR/conf/nginx.conf $NGINX_INSTALL_DIR/conf/nginx.conf-default
	cp $DEFAULT_DIR/conf/nginx.conf $NGINX_INSTALL_DIR/conf/
	mkdir -pv /data/{wwwroot,weblogs}
	mkdir -pv /data/wwwroot/htdocs
	chown -R www:www /data/wwwroot
	chown -R www:www /data/weblogs
	
else
	CFLAGS= CXXFLAGS= ./configure --prefix=$PHP_INSTALL_DIR --with-config-file-path=$PHP_INSTALL_DIR/etc --with-apxs2=$APACHE_INSTALL_DIR/bin/apxs --disable-fileinfo --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-iconv-dir=/usr/local --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-bcmath --enable-shmop --enable-exif --enable-sysvsem --enable-inline-optimization --with-curl --enable-mbregex --enable-mbstring --with-mcrypt --with-gd --enable-gd-native-ttf --with-openssl --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-ftp --with-gettext --enable-zip --enable-soap --disable-ipv6 --disable-debug
	make ZEND_EXTRA_LIBS='-liconv'
	make install && echo "INSTALL APACHE_PHP"
	sleep 10
	# Configure Apache
	sed -i '380a\   AddType application/x-httpd-php  .php' /etc/httpd/httpd.conf
	sed -i '381a\   AddType application/x-httpd-php-source  .phps' /etc/httpd/httpd.conf
	sed -i 's@DirectoryIndex@DirectoryIndex index.php@g' /etc/httpd/httpd.conf
	sed -i '194a\PHPIniDir "/usr/local/php/etc/php.ini"' /etc/httpd/httpd.conf
fi

if [ -d "$PHP_INSTALL_DIR" ]; then
        echo -e "\033[32mPHP install successfully! \033[0m"
	sleep 10
else
        echo -e "\033[31mPHP install failed, Please Contact the author! \033[0m"
        kill -9 $$
fi
cat >>/etc/profile.d/php.sh<<EOF
export PATH=\$PATH:$PHP_INSTALL_DIR/bin
EOF
source /etc/profile.d/php.sh

cp php.ini-production  /usr/local/php/etc/php.ini

# Modify php.ini
Mem=`free -m | awk '/Mem:/{print $2}'`
if [ $Mem -gt 1024 -a $Mem -le 1500 ]; then
        Memory_limit=192
elif [ $Mem -gt 1500 -a $Mem -le 3500 ]; then
        Memory_limit=256
elif [ $Mem -gt 3500 -a $Mem -le 4500 ]; then
        Memory_limit=320
elif [ $Mem -gt 4500 ]; then
        Memory_limit=448
else
        Memory_limit=128
fi

sed -i "s@^memory_limit.*@memory_limit = ${Memory_limit}M@" $PHP_INSTALL_DIR/etc/php.ini
sed -i 's@^output_buffering =@output_buffering = On\noutput_buffering =@' $PHP_INSTALL_DIR/etc/php.ini
sed -i 's@^;cgi.fix_pathinfo.*@cgi.fix_pathinfo=0@' $PHP_INSTALL_DIR/etc/php.ini
sed -i 's@^short_open_tag = Off@short_open_tag = On@' $PHP_INSTALL_DIR/etc/php.ini
sed -i 's@^expose_php = On@expose_php = Off@' $PHP_INSTALL_DIR/etc/php.ini
sed -i 's@^request_order.*@request_order = "CGP"@' $PHP_INSTALL_DIR/etc/php.ini
sed -i 's@^;date.timezone.*@date.timezone = "Asia/Shanghai"@' $PHP_INSTALL_DIR/etc/php.ini
sed -i 's@^post_max_size.*@post_max_size = 50M@' $PHP_INSTALL_DIR/etc/php.ini
sed -i 's@^upload_max_filesize.*@upload_max_filesize = 50M@' $PHP_INSTALL_DIR/etc/php.ini
sed -i 's@^;upload_tmp_dir.*@upload_tmp_dir = /tmp@' $PHP_INSTALL_DIR/etc/php.ini
sed -i 's@^max_execution_time.*@max_execution_time = 5@' $PHP_INSTALL_DIR/etc/php.ini
sed -i 's@^session.cookie_httponly.*@session.cookie_httponly = 1@' $PHP_INSTALL_DIR/etc/php.ini
sed -i 's@^mysqlnd.collect_memory_statistics.*@mysqlnd.collect_memory_statistics = On@' $PHP_INSTALL_DIR/etc/php.ini
}
