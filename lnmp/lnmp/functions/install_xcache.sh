INSTALL_XCACHE()
{
cd $DEFAULT_DIR/src
tar xzf xcache-3.2.0.tar.gz
cd xcache-3.2.0
$PHP_INSTALL_DIR/bin/phpize
./configure --enable-xcache --enable-xcache-coverager --enable-xcache-optimizer --with-php-config=$PHP_INSTALL_DIR/bin/php-config
make && make install
if [ -f "$PHP_INSTALL_DIR/lib/php/extensions/`ls $PHP_INSTALL_DIR/lib/php/extensions | grep zts`/xcache.so" ];then
	mkdir -pv $WEB_HTDOCS/{default,xcache}
        /bin/cp -R htdocs $WEB_HTDOCS/default/xcache
        chown -R www.www $WEB_HTDOCS/default/xcache
        touch /tmp/xcache;chown www.www /tmp/xcache

        Memtatol=`free -m | grep 'Mem:' | awk '{print $2}'`
        if [ $Memtatol -le 512 ];then
                xcache_size=40M
        elif [ $Memtatol -gt 512 -a $Memtatol -le 1024 ];then
                xcache_size=80M
        elif [ $Memtatol -gt 1024 -a $Memtatol -le 1500 ];then
                xcache_size=100M
        elif [ $Memtatol -gt 1500 -a $Memtatol -le 2500 ];then
                xcache_size=160M
        elif [ $Memtatol -gt 2500 -a $Memtatol -le 3500 ];then
                xcache_size=180M
        elif [ $Memtatol -gt 3500 ];then
                xcache_size=200M
        fi

        cat >> $PHP_INSTALL_DIR/etc/php.ini << EOF
[xcache-common]
extension = "xcache.so"
[xcache.admin]
xcache.admin.enable_auth = On
xcache.admin.user = "admin"
xcache.admin.pass = "$xcache_admin_md5_pass"

[xcache]
xcache.size  = $xcache_size 
xcache.count = $(expr `cat /proc/cpuinfo | grep -c processor` + 1) 
xcache.slots = 8K
xcache.ttl = 3600
xcache.gc_interval = 300
xcache.var_size = $xcache_size 
xcache.var_count = $(expr `cat /proc/cpuinfo | grep -c processor` + 1) 
xcache.var_slots = 8K
xcache.var_ttl = 0
xcache.var_maxttl = 0
xcache.var_gc_interval = 300
xcache.test = Off
xcache.readonly_protection = Off
xcache.shm_scheme = "mmap"
xcache.mmap_path = "/tmp/xcache"
xcache.coredump_directory = ""
xcache.cacher = On
xcache.stat = On
xcache.optimizer = Off

[xcache.coverager]
; enabling this feature will impact performance
; enable only if xcache.coverager == On && xcache.coveragedump_directory == "non-empty-value"
; enable coverage data collecting and xcache_coverager_start/stop/get/clean() functions
xcache.coverager = Off
xcache.coverager_autostart = On
xcache.coveragedump_directory = ""
EOF
        [ -d $NGINX_INSTALL_DIR ] && service php-fpm restart || service httpd restart
else
        echo -e "\033[31meXcache module install failed, Please contact the author! \033[0m"
fi
cd ..
/bin/rm -rf xcache-3.2.0
cd ..
}
