#!/usr/bin/env bash

# update and upgrade server
yum -y update && yum -y upgrade

# secure ssh (http://www.cyberciti.biz/tips/linux-unix-bsd-openssh-server-best-practices.html)
printf "\n# Custom config from script\n"

echo "AllowUsers root deployer" >> /etc/ssh/sshd_config

#sed -i 's/^#ClientAliveInterval.*/ClientAliveInterval 300/' /etc/ssh/sshd_config
#sed -i 's/^#ClientAliveCountMax.*/ClientAliveCountMax 0/' /etc/ssh/sshd_config

sed -i "s/^#IgnoreRhosts/IgnoreRhosts/g" /etc/ssh/sshd_config

sed -i "s/^#HostbasedAuthentication/HostbasedAuthentication/g" /etc/ssh/sshd_config

sed -i "s/^#PermitRootLogin.*/PermitRootLogin no/" /etc/ssh/sshd_config
sed -i "s/^#PermitEmptyPasswords.*/PermitEmptyPasswords no/" /etc/ssh/sshd_config

cat >> /etc/ssh/sshd_config <<EOL
#  Turn on privilege separation
UsePrivilegeSeparation yes
# Prevent the use of insecure home directory and key file permissions
StrictModes yes
# Do you need port forwarding?
AllowTcpForwarding no
X11Forwarding no
EOL

# install wget
yum -y install wget

# enable EPEL repo
wget http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
rpm -ivh epel-release-6-8.noarch.rpm
rm -f epel-release-6-8.noarch.rpm

# install and start denyhosts
yum -y update && yum -y install denyhosts
chkconfig denyhosts on
service denyhosts start

# securing server (http://www.cyberciti.biz/tips/linux-security.html)
yum -y erase inetd xinetd ypserv tftp-server telnet-server rsh-serve

cat >> /etc/sysctl.conf <<EOL
# Turn on execshield
kernel.exec-shield=1
kernel.randomize_va_space=1
# Enable IP spoofing protection
net.ipv4.conf.all.rp_filter=1
# Disable IP source routing
net.ipv4.conf.all.accept_source_route=0
# Ignoring broadcasts request
net.ipv4.icmp_echo_ignore_broadcasts=1
net.ipv4.icmp_ignore_bogus_error_messages=1
# Make sure spoofed packets get logged
net.ipv4.conf.all.log_martians = 1
EOL

# automatic update
yum -y install yum-cron
chkconfig yum-cron on
service yum-cron start

# create deployer user
useradd deployer

echo "IMPORTANT: Use 'passwd deployer' to set a password for the user"
echo "Now it's time to secure your Firewall server (https://github.com/jnaqsh/iptables_firewall/)"
