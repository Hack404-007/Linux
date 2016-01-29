#!/bin/bash
#modify 20140926

BASEDIR=$PWD
VERSION=nginx-1.8.0
NGINX=${VERSION}.tar.gz
DATADIR=/usr/local/nginx
DATE=`date +%F" "%T`
#
if [ -f $DATADIR/sbin/nginx ] ;then

echo "nginx has installed!  $DATE" >> /tmp/nginx.log
exit 1
fi

cd $BASEDIR
rm -f ${NGINX}
wget http://113.31.16.198:8889/nginx/${NGINX}
tar zxvf $NGINX

#cp -rf ngx_devel_kit $BASEDIR/${VERSION}
#cp -rf form-input-nginx-module $BASEDIR/${VERSION}
tar -xzvf  fastdfs-nginx-module_v1.16.tar.gz
mv fastdfs-nginx-module $BASEDIR/${VERSION}

cd $BASEDIR/${VERSION}

#
yum -y install gcc openssl-devel pcre-devel zlib-devel make patch

mkdir -p /usr/local/nginx/tmp/{client,proxy,fcgi}
useradd -u 602 nginx  -M -s /sbin/nologin
./configure \
  --prefix=/usr/local/nginx \
  --user=nginx \
  --group=nginx \
  --with-http_ssl_module \
  --with-http_gzip_static_module \
  --http-client-body-temp-path=/usr/local/nginx/tmp/client/ \
  --http-proxy-temp-path=/usr/local/nginx/tmp/proxy/ \
  --http-fastcgi-temp-path=/usr/local/nginx/tmp/fcgi/ \
  --with-poll_module \
  --with-file-aio \
  --with-http_realip_module \
  --with-http_addition_module \
  --with-http_random_index_module \
  --with-pcre \
  --with-http_stub_status_module \
  --add-module=$BASEDIR/${VERSION}/fastdfs-nginx-module/src 

if [ $? = 0 ];then

make && make install 
chown -R nginx.nginx  $DATADIR
else

exit 1

fi
