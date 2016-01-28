#!/bin/bash
#
INSTALL_ZENDOPCACHE()
{
cd $DEFAULT_DIR/src
tar xzf ZendOptimizerPlus-7.0.4.tar.gz
cd ZendOptimizerPlus-7.0.4
$PHP_INSTALL_DIR/bin/phpize
./configure --with-php-config=$PHP_INSTALL_DIR/bin/php-config
make && make install
Mem=$(free -m | awk '/Mem:/{print $2}')
if [ $Mem -gt 1024 -a $Mem -le 1500 ]; then
        Memory_limit=192
elif [ $Mem -gt 1500 -a $Mem -le 3500 ]; then
        Memory_limit=256
elif [ $Mem -gt 3500 -a $Mem -le 4500 ]; then
        Memory_limit=320
elif [ $Mem -gt 4500 ];then
        Memory_limit=448
else
        Memory_limit=128
fi
if [ -f "$PHP_INSTALL_DIR/lib/php/extensions/`ls $PHP_INSTALL_DIR/lib/php/extensions | grep zts`/opcache.so" ];then
        cat >> $PHP_INSTALL_DIR/etc/php.ini << EOF
[opcache]
zend_extension="$PHP_INSTALL_DIR/lib/php/extensions/`ls $PHP_INSTALL_DIR/lib/php/extensions | grep zts`/opcache.so"
opcache.memory_consumption=$Memory_limit
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=4000
opcache.revalidate_freq=60
opcache.save_comments=0
opcache.fast_shutdown=1
opcache.enable_cli=1
;opcache.optimization_level=0
EOF
	if [ -d $APACHE_INSTALL_DIR ]; then
		service httpd restart
	else
		service nginx restart
	fi
else
        echo -e "\033[31meZend OPcache module install failed, Please contact the author! \033[0m"
fi
/bin/rm -rf ZendOptimizerPlus-7.0.4
}
