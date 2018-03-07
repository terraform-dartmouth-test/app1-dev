#!/bin/bash
# AWS userdata script for server configuration.
# Following configuation changes are done:
#   - Install packages
#   - Selinux: switch to permissive from enforcing
#   - Password complexity 
#   - Journald config file modification for syslog-ng
#   - Update hostname by reverse DNS lookup	

LOG_FILE="/tmp/userdata.log"
echo "Creating test file" > $LOG_FILE

#### Install Packages ####
echo "Installing packages" >> $LOG_FILE
yum install telnet bind-utils -y
yum install lvm2 -y
yum install vim -y
yum install pam_krb5 -y
yum install redhat-lsb-core -y
yum install wget -y

#### set selinux to permissive mode ####
SELINUX_CONFIG_FILE="/etc/selinux/config"
echo "Updating configuration file $SELINUX_CONFIG_FILE" >> $LOG_FILE
if [ -f $SELINUX_CONFIG_FILE ];
then
   `cp $SELINUX_CONFIG_FILE $SELINUX_CONFIG_FILE".ks"`
fi

sed -i "s/SELINUX=enforcing/SELINUX=permissive/" $SELINUX_CONFIG_FILE

#### Password Complexity ####
PWQUALITY_CONFIG_FILE="/etc/security/pwquality.conf"
echo "Updating configuration file $PWQUALITY_CONFIG_FILE" >> $LOG_FILE
if [ -f $PWQUALITY_CONFIG_FILE ];
then
   `cp $PWQUALITY_CONFIG_FILE $PAMD_PASSWD_CONFIG_FILE".ks"`
fi

cat >> $PWQUALITY_CONFIG_FILE <<_EOF_
# kickstart added
# for password complexity
minlen = 12
dcredit = -1
ucredit = -1
lcredit = -1
ocredit = -1
_EOF_

#### Enable ForwardToSyslog option on journald config ####
JOURNALD_CONFIG_FILE="/etc/systemd/journald.conf"
echo "Updating configuration file $JOURNALD_CONFIG_FILE" >> $LOG_FILE
if [ -f $JOURNALD_CONFIG_FILE ];
then
   `cp $JOURNALD_CONFIG_FILE $JOURNALD_CONFIG_FILE".ks"`
fi

sed -i "s/#ForwardToSyslog=yes/ForwardToSyslog=yes/" /etc/systemd/journald.conf

# Restart journald after change
systemctl restart systemd-journald.service


#### Set hostname ####
# Wait for DNS to propagate
echo "Going to sleep 2m for DNS to propagate" >> $LOG_FILE
sleep 2m

# Dependency: redhat-lsb-core package needs to be installed

host_ip=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
echo "Host IP: $host_ip" >> $LOG_FILE

dns_name=$(getent hosts $host_ip | awk '{print $2}')
echo "DNS Host Name: $dns_name" >> $LOG_FILE

majversion=$(lsb_release -rs | cut -f1 -d.)
if [ $majversion -eq '6' ]
then
   echo "Major version: lsb_release 6" >> $LOG_FILE
   sed -i "s/HOSTNAME=.*/HOSTNAME=$dns_name/g" /etc/sysconfig/network

   # Preserve the hostname
   # DHCP will override otherwise
   echo "preserve_hostname: true" >> /etc/cloud/cloud.cfg

   /sbin/service network restart

elif [ $majversion -eq '7' ]
then
   echo "Major version: lsb_release 7" >> $LOG_FILE
   $(hostnamectl set-hostname $dns_name)
   # Preserve the hostname
   # DHCP will override otherwise
   echo "preserve_hostname: true" >> /etc/cloud/cloud.cfg
else
   echo "Setting up hostname not supprted"
   exit 1
fi

# Set timezone to EST
echo "Setting time zone to EST" >> $LOG_FILE
/usr/bin/timedatectl set-timezone  America/New_York
