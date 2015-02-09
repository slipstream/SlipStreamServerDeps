#!/bin/sh

yum install -y ntp
service ntpd start

yum install -y nagios nagios-plugins-all nagios-plugins-nrpe httpd php

# Install Slack notifications
yum install perl-libwww-perl perl-Net-SSLeay perl-Crypt-SSLeay
wget --no-check-certificate -O /usr/local/bin/slack_nagios.pl \
     https://raw.github.com/tinyspeck/services-examples/master/nagios.pl
chmod 755 /usr/local/bin/slack_nagios.pl
echo 'MANUAL STEP IS REQUIRED
# Edit /usr/local/bin/slack_nagios.pl according to 
# https://sixsq.slack.com/services/B026T5CM7
#my $opt_domain = "sixsq.slack.com"; # Your team domain
#my $opt_token = "set me""; # The token from your Nagios services page'
