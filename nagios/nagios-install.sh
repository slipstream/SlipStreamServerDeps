#!/bin/sh

# install all required packages (git, slack, nagios, ...)
yum install -y epel-release
yum clean all
yum install -y git wget python-pip \
    ntp nagios nagios-plugins-all nagios-plugins-nrpe httpd php jq \
    perl-libwww-perl perl-Net-SSLeay perl-Crypt-SSLeay

# install SlipStream client
pip install slipstream-client

# disable SELinux
setenforce 0
sed s/SELINUX=enforcing/SELINUX=permissive/g -i /etc/selinux/config

# enable services
systemctl enable nagios
systemctl enable httpd
systemctl enable ntpd

# install sixsq monitoring targets
cd /root
git clone https://github.com/slipstream/SlipStreamServerDeps.git
command cp -R --remove-destination /root/SlipStreamServerDeps/nagios/etc/nagios/* /etc/nagios/

command cp --remove-destination /root/SlipStreamServerDeps/nagios/usr/lib64/nagios/plugins/* /usr/lib64/nagios/plugins/
command cp --remove-destination /root/SlipStreamServerDeps/nagios/usr/bin/* /usr/bin/

# fix ownership and permissions
chown -R root:nagios /etc/nagios
chgrp apache /etc/nagios/passwd
usermod -G apache,nagios apache

# start services
systemctl start ntpd
systemctl start nagios
systemctl start httpd

# Install Slack notifications
yum install -y perl-libwww-perl perl-Net-SSLeay perl-Crypt-SSLeay
wget --no-check-certificate -O /usr/local/bin/slack_nagios.pl \
     https://raw.github.com/tinyspeck/services-examples/master/nagios.pl
chmod 755 /usr/local/bin/slack_nagios.pl

echo 'MANUAL STEP IS REQUIRED
# Edit /usr/local/bin/slack_nagios.pl according to 
# https://sixsq.slack.com/services/B026T5CM7
#my $opt_domain = "sixsq.slack.com"; # Your team domain
#my $opt_token = "set me""; # The token from your Nagios services page

# Update the files /etc/nagios/private/resource.cfg with the 
# required credentials for the checks.'
