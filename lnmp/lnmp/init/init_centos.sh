#!/bin/bash
#
# Trun off selinux
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
# User add sudo power
/usr/sbin/useradd coolplayjamesmengroot
echo 'coolplay@4c8mr47n3f5g6hj$$20141002' | passwd --stdin coolplayjamesmengroot  && history -c
sed -i '108a\coolplayjamesmengroot    ALL=(ALL)       NOPASSWD: ALL' /etc/sudoers
# Empty iptables rules
#!/bin/bash
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
# Update kernel system
yum update -y
# Install basic packet
yum -y install gcc gcc-c++ autoconf libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel libxml2 libxml2-devel zlib zlib-devel glibc glibc-devel glib2 glib2-devel bzip2 bzip2-devel ncurses ncurses-devel curl curl-devel e2fsprogs e2fsprogs-devel krb5 krb5-devel libidn libidn-devel openssl openssl-devel openldap openldap-devel nss_ldap openldap-clients openldap-servers setuptool ntsysv system-config-securitylevel-tui system-config-network-tui openssl vim wget make bind-utils ntp gcc gcc-c++ ncurses-devel libxml2 libxml2-devel cmake ntp lsof
# Update system time_zone
yum install lrzzs ntpdate sysstat -y
echo '*/5 * * * * root /usr/sbin/ntpdate time.windows.com > /dev/null 2>&1' >> /var/spool/cron/root
echo '*/10 * * * * root /usr/sbin/ntpdate time.nist.gov > /dev/null 2>&1' >> /var/spool/cron/root
# Trun off some service about noting
for sun in `chkconfig  --list | grep 3:on | awk '{print $1}'`;do chkconfig --level 3 $sun off;done
for sun in crond rsyslog sshd network;do chkconfig --level 3 $sun on;done
# Cchange default sshd port
sed -i '/#Port 22/s/#Port 22/Port 65535/' /etc/ssh/sshd_config
sed -i '/#PermitRootLogin yes/s/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i '/#PermitEmptyPasswords no/s/#PermitEmptyPasswords no/PermitEmptyPasswords no/' /etc/ssh/sshd_config
sed -i '/#UseDNS yes/s/#UseDNS yes/UseDNS no/' /etc/ssh/sshd_config
if [ $? -eq 0 ]; then
        /etc/init.d/sshd  restart
else
        exit 1
fi
# Lock file system impotant
#chattr +i /etc/passwd
#chattr +i /etc/inittab
#chattr +i /etc/group
#chattr +i /etc/shadow
#chattr +i /etc/gshadow
# Rename chattr word
#mv /usr/bin/chattr /usr/bin/mvchattr
# Descriptor file Symbol
ulimit -SHn 65535
echo '*  -  nofile  65535' >> /etc/security/limits.conf
echo  'ulimit -SHn 65535' >> /etc/rc.local
echo 'ulimit  -s 65535' >> /etc/rc.local
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
exit 0
