#!/bin/bash
#
INSTALL_ZendGuardLoader()
{
cd $DEFAULT_DIR/src/php_accelerate

php_version=`$PHP_INSTALL_DIR/bin/php -r 'echo PHP_VERSION;'`
PHP_version=${php_version%.*}

[ ! -e "$PHP_INSTALL_DIR/lib/php/extensions/" ] && mkdir $PHP_INSTALL_DIR/lib/php/extensions/
if [ `getconf WORD_BIT` == 32 ] && [ `getconf LONG_BIT` == 64 ] ;then
        if [ "$PHP_version" == '5.6' ];then
                tar xzf zend-loader-php5.6-linux-x86_64.tar.gz
                /bin/cp zend-loader-php5.6-linux-x86_64/ZendGuardLoader.so $PHP_INSTALL_DIR/lib/php/extensions/
                /bin/rm -rf zend-loader-php5.6-linux-x86_64
        fi

        if [ "$PHP_version" == '5.5' ];then
                tar xzf zend-loader-php5.5-linux-x86_64.tar.gz
                /bin/cp zend-loader-php5.5-linux-x86_64/ZendGuardLoader.so $PHP_INSTALL_DIR/lib/php/extensions/
                /bin/rm -rf zend-loader-php5.5-linux-x86_64
        fi

        if [ "$PHP_version" == '5.4' ];then
                tar xzf ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64.tar.gz
                /bin/rm -rf ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64
        fi

        if [ "$PHP_version" == '5.3' ];then
                /bin/rm -rf ZendGuardLoader-php-5.3-linux-glibc23-x86_64
        fi
else
        if [ "$PHP_version" == '5.6' ];then
                tar xzf zend-loader-php5.6-linux-i386.tar.gz
                /bin/cp zend-loader-php5.6-linux-i386/ZendGuardLoader.so $PHP_INSTALL_DIR/lib/php/extensions/
                /bin/rm -rf zend-loader-php5.6-linux-i386
        fi

        if [ "$PHP_version" == '5.5' ];then
                tar xzf zend-loader-php5.5-linux-i386.tar.gz
                /bin/cp zend-loader-php5.5-linux-i386/ZendGuardLoader.so $PHP_INSTALL_DIR/lib/php/extensions/
                /bin/rm -rf zend-loader-php5.5-linux-x386
        fi

        if [ "$PHP_version" == '5.4' ];then
                tar xzf ZendGuardLoader-70429-PHP-5.4-linux-glibc23-i386.tar.gz
                /bin/cp ZendGuardLoader-70429-PHP-5.4-linux-glibc23-i386/php-5.4.x/ZendGuardLoader.so $PHP_INSTALL_DIR/lib/php/extensions/
                /bin/rm -rf ZendGuardLoader-70429-PHP-5.4-linux-glibc23-i386
        fi

        if [ "$PHP_version" == '5.3' ];then
                tar xzf ZendGuardLoader-php-5.3-linux-glibc23-i386.tar.gz
                /bin/cp ZendGuardLoader-php-5.3-linux-glibc23-i386/php-5.3.x/ZendGuardLoader.so $PHP_INSTALL_DIR/lib/php/extensions/
                /bin/rm -rf ZendGuardLoader-php-5.3-linux-glibc23-i386
        fi
fi

if [ -f "$PHP_INSTALL_DIR/lib/php/extensions/ZendGuardLoader.so" ];then
        cat >> $PHP_INSTALL_DIR/etc/php.ini << EOF
[Zend Guard Loader]
zend_extension="/usr/local/php/lib/php/extensions/ZendGuardLoader.so"
zend_loader.enable=1
zend_loader.disable_licensing=0
zend_loader.obfuscation_level_support=3
EOF
	service httpd status && service httpd restart || service nginx status && service nginx restart
else
        echo -e "\033[31meZendGuardLoader module install failed, Please contact the author! \033[0m"
fi
}
