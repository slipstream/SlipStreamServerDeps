#!/bin/bash

set -e

NAGIOS_OK=0
NAGIOS_CRITICAL=2

CONFIG=/etc/slipstream/slipstream-backup.conf

source $CONFIG

if [ -z "${AMAZON_BUCKET}" ]; then
    echo "CRITICAL: Define Amazon S3 bucket in $CONFIG."
    exit $NAGIOS_CRITICAL
fi
if [ -z "${SS_HOSTNAME}" ]; then
    echo "CRITICAL: Define the host IP/hostname in $CONFIG."
    exit $NAGIOS_CRITICAL
fi

LOGS_DIR=/opt/slipstream/server/logs
FIRST=$(cd $LOGS_DIR; ls -1 -t --ignore $(date +%Y_%m_%d)* . | tail -1 | awk -F. '{print $1}')
LAST=$(cd $LOGS_DIR; ls -1 -t --ignore $(date +%Y_%m_%d)* . | head -1 | awk -F. '{print $1}')

BUNDLE_NAME=slipstream.logs.${SS_HOSTNAME}.$FIRST-$LAST.$(date --utc "+%Y-%m-%dT%H%MZ")
BUNDLE=/tmp/$BUNDLE_NAME

cleanup() {
    sudo /bin/rm -f $BUNDLE
}

trap cleanup EXIT

output=$(sudo /usr/bin/gpg-zip --encrypt --gpg-args "--yes --trust-model always -r SixSq" --output $BUNDLE $LOGS_DIR 2>&1)
if [ "$?" -ne "0" ]; then
    echo -e "CRITICAL: Failed to gpg-zip backup.\n$output"
    exit $NAGIOS_CRITICAL
fi

BACKUP=$AMAZON_BUCKET/$BUNDLE_NAME
output=$(sudo /opt/slipstream/backup/s3curl.pl --id sixsq --put $BUNDLE -- $BACKUP 2>&1)
if [ "$?" -ne "0" ]; then
    echo -e "CRITICAL: Failed to upload to S3.\n$output"
    exit $NAGIOS_CRITICAL
fi

# Delete all but last log files
output=$(cd $LOGS_DIR; ls -1 -t --ignore $(date +%Y_%m_%d)* . | xargs rm -f)
if [ "$?" -eq "0" ]; then
    echo -e "OK: SlipStream Logs Backup Successful.\n$BACKUP"
    exit $NAGIOS_OK
else
    echo -e "CRITICAL: Failed to cleanup.\n$output"
    exit $NAGIOS_CRITICAL
fi
