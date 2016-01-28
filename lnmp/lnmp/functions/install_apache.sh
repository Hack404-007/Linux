
INSTALL_APACHE()
{
cd $DEFAULT_DIR/src
tar xzf pcre-8.36.tar.gz
cd pcre-8.36
./configure
make && make install
cd ../

useradd -M -s /sbin/nologin www
tar xzf httpd-2.4.12.tar.gz
tar xzf apr-1.5.1.tar.gz
tar xzf apr-util-1.5.4.tar.gz
cd httpd-2.4.12
/bin/cp -R ../apr-1.5.1 ./srclib/apr
/bin/cp -R ../apr-util-1.5.4 ./srclib/apr-util
./configure --prefix=$APACHE_INSTALL_DIR --sysconfdir=/etc/httpd  --enable-headers --enable-deflate --enable-mime-magic --enable-so --enable-rewrite --enable-ssl --with-ssl --enable-cgi --enable-modules=most --enable-mods-shared=most --enable-mpms-shared=all --enable-expires --enable-static-support --enable-suexec --disable-userdir --with-included-apr --with-mpm=prefork --disable-userdir
make && make install && echo "install OK"

if [ -d "$APACHE_INSTALL_DIR" ]; then
	echo -e "\033[32mApache install successfully! \033[0m"
	sleep 4
else
	echo -e "\033[31mApache install failed, Please contact the author! \033[0m"
	kill -9 $$
fi

cat >>/etc/profile.d/apache.sh<<EOF
export PATH=\$PATH:$APACHE_INSTALL_DIR/bin
EOF
source /etc/profile.d/apache.sh
cd ../
[ -d "$APACHE_INSTALL_DIR" ] && /bin/rm -rf httpd-2.4.12
/bin/cp $APACHE_INSTALL_DIR/bin/apachectl  /etc/init.d/httpd
sed -i '2a # chkconfig: - 85 15' /etc/init.d/httpd
sed -i '3a # description: Apache is a World Wide Web server. It is used to serve' /etc/init.d/httpd
chmod +x /etc/init.d/httpd
chkconfig --add httpd
chkconfig httpd on

sed -i 's/#ServerName www.example.com:80/ServerName localhost:80/g' /etc/httpd/httpd.conf
sed -i 's@^User daemon@User www@' /etc/httpd/httpd.conf
sed -i 's@^Group daemon@Group www@' /etc/httpd/httpd.conf
service httpd start > /dev/null 2>&1
lsof -i:80
if [ $? -eq 0 ]; then
	echo -e  "\033[32mApache is Running...\033[0m"
	sleep 10
else
	echo "Apache is Stoped..."
fi	
}
