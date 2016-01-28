CHECK_SYSTEM_OS()
{
echo "Check The System Environment..."
sleep 1

if [ $UID != 0 ]; then
	echo "You Must Run This Script as root"
	exit 0
fi

# Install Dependency  Package
echo "Install The Dependency Package..."
sleep 1
OS_NAME=$(cat /etc/issue  | head -n1 | awk {'print $1'})
if [ "$OS_NAME" == "CentOS" ]; then
	echo " Install Packetc"
	yum update -y
	for Package in gcc gcc-c++ make cmake autoconf libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel libxml2 libxml2-devel zlib zlib-devel glibc glibc-devel glib2 glib2-devel bzip2 bzip2-devel ncurses ncurses-devel libaio curl curl-devel e2fsprogs e2fsprogs-devel krb5-devel libidn libidn-devel openssl openssl-devel libxslt-devel libevent-devel libtool libtool-ltdl bison gd-devel vim-enhanced pcre-devel zip unzip ntpdate sysstat patch bc expect rsync git bison vim lsof
do
        yum -y install $Package
done
elif [ $OS_NAME == 'Ubuntu' ]; then
	echo "Install Packetc"
	apt-get update -y
	for Package in gcc g++ make cmake autoconf libjpeg8 libjpeg8-dev libpng12-0 libpng12-dev libpng3 libfreetype6 libfreetype6-dev libxml2 libxml2-dev zlib1g zlib1g-dev libc6 libc6-dev libglib2.0-0 libglib2.0-dev bzip2 libzip-dev libbz2-1.0 libncurses5 libncurses5-dev libaio1 libaio-dev curl libcurl3 libcurl4-openssl-dev e2fsprogs libkrb5-3 libkrb5-dev libltdl-dev libidn11 libidn11-dev openssl libssl-dev libtool libevent-dev re2c libsasl2-dev libxslt1-dev patch vim zip unzip tmux htop wget bc expect rsync git bison
do
        apt-get -y install $Package
done
else
	echo "Unknow System,Quiting..."
	exit 0	
fi	
}
