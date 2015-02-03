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

cleanup() {
    rm -f $BUNDLE
}

trap cleanup EXIT

n="
"
gpg-zip --encrypt --gpg-args "--yes --trust-model always -r SixSq" \
    --output $BUNDLE $SS_DB ${SS_CONF#$n} $SS_REPORTS

BACKUP=$AMAZON_BUCKET/$BUNDLE_NAME

output=$(/opt/slipstream/backup/s3curl.pl --id sixsq --put $BUNDLE -- -f $BACKUP 2>&1)
[ "$?" -eq "0" ] && \
    echo "SlipStream Backup Successful. $BACKUP" || \
    echo "FAILURE $BACKUP: $output"

exit 0
