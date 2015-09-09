#!/bin/bash

export LANG=en_US.utf8

set -e

CONFIG=/etc/slipstream/slipstream-backup.conf

source $CONFIG

AMAZON_BUCKET=${AMAZON_BUCKET:?"Define Amazon S3 bucket in $CONFIG."}
SS_HOSTNAME=${SS_HOSTNAME:?"Define the host IP/hostname in $CONFIG."}

BUNDLE_NAME=slipstream.backup.${SS_HOSTNAME}.$(date --utc "+%Y-%m-%dT%H%MZ")
BUNDLE=/tmp/$BUNDLE_NAME

SS_DB=/opt/slipstream/SlipStreamDB/
SS_CONF=$(find /opt/slipstream/server -name "default.config.properties" -o -name slipstream.xml)
SS_REPORTS=$([ -d /var/tmp/slipstream/reports ] && echo /var/tmp/slipstream/reports)

BACKUP_TIMESTAMP=${BACKUP_TIMESTAMP:-"/var/log/slipstream-backup-timestamp"}

cleanup() {
    rm -f $BUNDLE
}

trap cleanup EXIT

n="
"
gpg-zip --encrypt --gpg-args "--yes --trust-model always -r SixSq" \
    --output $BUNDLE $SS_DB ${SS_CONF#$n} $SS_REPORTS

BACKUP=$AMAZON_BUCKET/$BUNDLE_NAME

set +e
output=$(/opt/slipstream/backup/s3curl.pl --id sixsq --put $BUNDLE -- -f $BACKUP 2>&1)
rc=$?
if [ "$rc" -eq "0" ]; then
    echo "SlipStream Backup Successful. $BACKUP"
    touch ${BACKUP_TIMESTAMP}
else
    echo "FAILURE $BACKUP: $output"
fi
exit $rc
