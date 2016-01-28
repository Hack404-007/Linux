INSTALL_NGINX()
{
cd $DEFAULT_DIR/src
tar xzf pcre-8.36.tar.gz
cd pcre-8.36
./configure
make && make install
cd ../

tar jxvf jemalloc-3.4.0.tar.bz2
cd jemalloc-3.4.0
./configure
make && make install
echo '/usr/local/lib' >> /etc/ld.so.conf.d/local.conf
ldconfig  -v > /dev/null 2>&1
cd ../

tar xzf nginx-1.8.0.tar.gz
useradd -M -s /sbin/nologin www
cd nginx-1.8.0
# Modify Nginx version
sed -i 's@#define NGINX_VERSION.*$@#define NGINX_VERSION      "1.2"@' src/core/nginx.h
sed -i 's@#define NGINX_VER.*NGINX_VERSION$@#define NGINX_VER          "BWS/" NGINX_VERSION@' src/core/nginx.h
# close debug
sed -i 's@CFLAGS="$CFLAGS -g"@#CFLAGS="$CFLAGS -g"@' auto/cc/gcc

./configure --prefix=$NGINX_INSTALL_DIR --user=www --group=www --with-http_stub_status_module --with-http_spdy_module --with-http_ssl_module --with-ipv6 --with-http_gzip_static_module --with-http_realip_module --with-http_flv_module --with-ld-opt='-ljemalloc'
make && make install
if [ -d "$NGINX_INSTALL_DIR" ];then
        echo -e "\033[32mNginx install successfully! \033[0m"
else
        echo -e "\033[31mNginx install failed, Please Contact the author! \033[0m"
        kill -9 $$
fi

cat >>/etc/profile.d/nginx.sh<<EOF
export PATH=\$PATH:$NGINX_INSTALL_DIR/sbin
EOF
source /etc/profile.d/nginx.sh
cd ../../
OS_NAME=$(cat /etc/issue  | head -n1 | awk {'print $1'})
if [ $OS_NAME == "CentOS" ]; then
	cp init/nginx_centos /etc/init.d/nginx
	chkconfig --add nginx
	chkconfig nginx on
elif [ $OS_NAME == "Ubuntu" ]; then
	/bin/cp init/nginx_ubuntu /etc/init.d/nginx
	update-rc.d nginx defaults
fi
sed -i "s@/usr/local/nginx@$NGINX_INSTALL_DIR@g" /etc/init.d/nginx


# worker_cpu_affinity
CPU_num=`cat /proc/cpuinfo | grep processor | wc -l`
if [ $CPU_num == 2 ];then
        sed -i 's@^worker_processes.*@worker_processes 2;\nworker_cpu_affinity 10 01;@' $NGINX_INSTALL_DIR/conf/nginx.conf
elif [ $CPU_num == 3 ];then
        sed -i 's@^worker_processes.*@worker_processes 3;\nworker_cpu_affinity 100 010 001;@' $NGINX_INSTALL_DIR/conf/nginx.conf
elif [ $CPU_num == 4 ];then
        sed -i 's@^worker_processes.*@worker_processes 4;\nworker_cpu_affinity 1000 0100 0010 0001;@' $NGINX_INSTALL_DIR/conf/nginx.conf
elif [ $CPU_num == 6 ];then
        sed -i 's@^worker_processes.*@worker_processes 6;\nworker_cpu_affinity 100000 010000 001000 000100 000010 000001;@' $NGINX_INSTALL_DIR/conf/nginx.conf
elif [ $CPU_num == 8 ];then
        sed -i 's@^worker_processes.*@worker_processes 8;\nworker_cpu_affinity 10000000 01000000 00100000 00010000 00001000 00000100 00000010 00000001;@' $NGINX_INSTALL_DIR/conf/nginx.conf
else
        echo "Google worker_cpu_affinity"
fi

service nginx  start
lsof -i:80 > /dev/null 2>&1
if [ $? -eq 0 ]; then
        echo "Nginx is Running..."
else
        echo "Nginx is Stoped..."
fi
}

