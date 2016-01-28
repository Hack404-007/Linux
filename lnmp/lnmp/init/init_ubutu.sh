#!/bin/bash
# Author by: Tommy.Gandolf
#

# Set strong Pssword for  sudouser
useradd -mr coolplayadmin1
#Sudo_user=`grep '/bin/bash' /etc/passwd | grep -v "x:0"| awk 'BEGIN{FS=":"} {print $1}'`
echo "coolplayadmin1:1q2w3e4r5t6y" | chpasswd  &&  history  -c
sed -i "23a\coolplayadmin1 ALL=(ALL) ALL" /etc/sudoers
sed -i "31a\Defaults editor=/usr/bin/vim, env_editor" /etc/sudoers
# Replace sources to 163 sources
mv /etc/apt/sources.list /etc/apt/sources.list.bak
cat /etc/apt/sources.list<<EOF
deb http://mirrors.163.com/ubuntu/ precise main restricted
deb-src http://mirrors.163.com/ubuntu/ precise main restricted
deb http://mirrors.163.com/ubuntu/ precise-updates main restricted
deb-src http://mirrors.163.com/ubuntu/ precise-updates main restricted
deb http://mirrors.163.com/ubuntu/ precise universe
deb-src http://mirrors.163.com/ubuntu/ precise universe
deb http://mirrors.163.com/ubuntu/ precise-updates universe
deb-src http://mirrors.163.com/ubuntu/ precise-updates universe
deb http://mirrors.163.com/ubuntu/ precise multiverse
deb-src http://mirrors.163.com/ubuntu/ precise multiverse
deb http://mirrors.163.com/ubuntu/ precise-updates multiverse
deb-src http://mirrors.163.com/ubuntu/ precise-updates multiverse
deb http://mirrors.163.com/ubuntu/ precise-backports main restricted universe multiverse
deb-src http://mirrors.163.com/ubuntu/ precise-backports main restricted universe multiverse
deb http://mirrors.163.com/ubuntu/ precise-security main restricted
deb-src http://mirrors.163.com/ubuntu/ precise-security main restricted
deb http://mirrors.163.com/ubuntu/ precise-security universe
deb-src http://mirrors.163.com/ubuntu/ precise-security universe
deb http://mirrors.163.com/ubuntu/ precise-security multiverse
deb-src http://mirrors.163.com/ubuntu/ precise-security multiverse
deb http://extras.ubuntu.com/ubuntu precise main
deb-src http://extras.ubuntu.com/ubuntu precise main
gpg --keyserver keyserver.ubuntu.com --recv 16126D3A3E5C1192 > /dev/null 2>&1
EOF
gpg --export --armor 3E5C1192 | apt-key add –
# Remove unnecessary installation package
for Package in apache2 apache2-doc apache2-utils apache2.2-common apache2.2-bin apache2-mpm-prefork apache2-doc apache2-mpm-worker mysql-client mysql-server mysql-common php5 php5-common php5-cgi php5-mysql php5-curl php5-gd libmysql* mysql-*
do
	apt-get -y remove $Package 
done
dpkg -l | grep ^rc | awk '{print $2}' | xargs dpkg -P

# Update system
apt-get update && apt-get upgrade
apt-get dist-upgrade
apt-get autoclean
apt-get install update-manager-core
do-release-upgrade
# Install needed packages
for Package in gcc g++ make autoconf libjpeg8 libjpeg8-dev libpng12-0 libpng12-dev libpng3 libfreetype6 libfreetype6-dev libxml2 libxml2-dev zlib1g zlib1g-dev libc6 libc6-dev libglib2.0-0 libglib2.0-dev bzip2 libzip-dev libbz2-1.0 libncurses5 libncurses5-dev curl libcurl3 libcurl4-openssl-dev e2fsprogs libkrb5-3 libkrb5-dev libltdl-dev libidn11 libidn11-dev openssl libtool libevent-dev bison libsasl2-dev libxslt1-dev patch vim zip unzip tmux htop wget bc expect rsync
do
	apt-get -y install $Package
done

if [ ! -z "`cat /etc/issue |  grep 13`" ]; then
	apt-get -y install libcloog-ppl1
elif [ ! -z "`cat /etc/issue | grep 12`" ]; then
	apt-get -y install libcloog-ppl0
fi
# History size 
sed -i 's/HISTSIZE=.*$/HISTSIZE=100/g' ~/.bashrc
#[ -z "`cat ~/.bashrc | grep history-timestamp`" ] && echo "export PROMPT_COMMAND='{ msg=\$(history 1 | { read x y; echo \$y; });user=\$(whoami); echo \$(date \"+%Y-%m-%d %H:%M:%S\"):\$user:\`pwd\`/:\$msg ---- \$(who am i); } >> /tmp/\`hostname\`.\`whoami\`.history-timestamp'" >> ~/.bashrc

# /etc/security/limits.conf
[ -z "`cat /etc/security/limits.conf | grep 'nproc 65535'`" ] && cat >> /etc/security/limits.conf <<EOF
* soft nproc 65535
* hard nproc 65535
* soft nofile 65535
* hard nofile 65535
EOF
[ -z "`cat /etc/rc.local | grep 'ulimit -SH 65535'`" ] && echo "ulimit -SH 65535" >> /etc/rc.local
# /etc/hosts
#[ "$(hostname -i | awk '{print $1}')" != "127.0.0.1" ] && sed -i "s@^127.0.0.1\(.*\)@127.0.0.1   `hostname` \1@" /etc/hosts
# Set time zone
# Set timezone
rm -rf /etc/localtime
ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
# alias vi
#[ -z "`cat ~/.bashrc | grep 'alias vi='`" ] && sed -i "s@^alias l=\(.*\)@alias l=\1\nalias vi='vim'@" ~/.bashrc

# /etc/sysctl.conf
[ -z "`cat /etc/sysctl.conf | grep 'fs.file-max'`" ] && cat >> /etc/sysctl.conf << EOF
fs.file-max=65535
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_fin_timeout = 30 
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_tw_recycle = 1
net.ipv4.ip_local_port_range = 1024 65000
net.ipv4.tcp_max_syn_backlog = 262144
net.ipv4.tcp_max_tw_buckets = 6000
net.ipv4.route.gc_timeout = 100
net.ipv4.tcp_syn_retries = 1
net.ipv4.tcp_synack_retries = 1
net.core.somaxconn = 65535 
net.core.netdev_max_backlog = 262144
net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_max_orphans = 262144
EOF
sysctl -p
sed -i 's@^ACTIVE_CONSOLES.*@ACTIVE_CONSOLES="/dev/tty[1-2]"@' /etc/default/console-setup 
sed -i 's@^@#@g' /etc/init/tty[3-6].conf
echo 'en_US.UTF-8 UTF-8' > /var/lib/locales/supported.d/local
sed -i 's@^@#@g' /etc/init/control-alt-delete.conf
# Update time
ntpdate pool.ntp.org 
echo "*/20 * * * * `which ntpdate` pool.ntp.org > /dev/null 2>&1" >> /var/spool/cron/crontabs/root;chmod 600 /var/spool/cron/crontabs/root 
service cron restart
# iptables
cat > /etc/iptables.up.rules << EOF
# Firewall configuration written by system-config-securitylevel
# Manual customization of this file is not recommended.
*filter
:INPUT DROP [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
:syn-flood - [0:0]
-A INPUT -i lo -j ACCEPT
-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 80 -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 443 -j ACCEPT
-A INPUT -p icmp -m limit --limit 100/sec --limit-burst 100 -j ACCEPT
-A INPUT -p icmp -m limit --limit 1/s --limit-burst 10 -j ACCEPT
-A INPUT -p tcp -m tcp --tcp-flags FIN,SYN,RST,ACK SYN -j syn-flood
-A INPUT -j REJECT --reject-with icmp-host-prohibited
-A syn-flood -p tcp -m limit --limit 3/sec --limit-burst 6 -j RETURN
-A syn-flood -j REJECT --reject-with icmp-port-unreachable
COMMIT
EOF
iptables-restore < /etc/iptables.up.rules
echo 'pre-up iptables-restore < /etc/iptables.up.rules' >> /etc/network/interfaces
. ~/.bashrc
# Trun off and trun on System service
apt-get install  sysv-rc-conf -y
ALL_SERVICES=`sysv-rc-conf --list | awk 'BEGIN {FS=" "} {print $1}'`
SKIP_SERVICES="dns-clean grub-common ondemand rc.local rsync sudo  ufw ssh"
for i in ${ALL_SERVICES}
do
        sysv-rc-conf  --level 2 $i off
        for n in ${SKIP_SERVICES}
        do
                sysv-rc-conf  --level 2 $n on
        done
done
echo ""
echo "Ubuntu 14.04 init ok ... "
exit 0
