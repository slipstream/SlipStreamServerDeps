#!/bins/sh -ex

SERVER=${1:?"Provide server IP/hostname."}

SSH_OPTIONS="-i $HOME/.ssh/id-sixsq-admin-amazon"
SSH_OPTIONS=

trap "unset ssh scp" EXIT

function ssh() {
    ssh $SSH_OPTIONS root@$SERVER $@
}

function scp() {
    REMOTE=${2:-~}
    scp $SSH_OPTIONS $1 root@$SERVER:$REMOTE 
}

scp nagios-install.sh
ssh chmod 755 ~/nagios-install.sh
ssh ~/nagios-install.sh

tar -C etc/nagios -zc * -f etc.nagios.tgz
scp etc.nagios.tgz
ssh tar -C /etc/nagios -zxvf etc.nagios.tgz
ssh service nagios start

# Make sure /etc/nagios/passwd can be read by a group under which httpd is running
ssh chgrp apache /etc/nagios/passwd

# To solve "Error: Could not read object configuration data!" issue 
ssh usermod -G apache,nagios apache
ssh service httpd start
