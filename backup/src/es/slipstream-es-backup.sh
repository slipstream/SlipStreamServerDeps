#!/bin/bash

export LANG=en_US.utf8

set -e

CONFIG=/etc/slipstream/slipstream-es-backup.conf

source $CONFIG

BACKUP_TIMESTAMP=${BACKUP_TIMESTAMP:-"/var/log/slipstream-es-backup-timestamp"}

# Note that snapshot name must be lowercase (required by ES).
BACKUP_NAME=es.snapshot.$SS_HOSTNAME.$(date --utc "+%Y-%m-%dt%H%Mz")

ES="${ES_HOST-localhost}:${ES_PORT-9200}"
set +e
output=$(curl -sSf -XPUT http://$ES/_snapshot/es_backup/$BACKUP_NAME?wait_for_completion=true 2>&1)
rc=$?
set -e
if [ "$rc" -eq "0" ]; then
    echo "SlipStream ES Backup Successful. $BACKUP_NAME. $output"
    touch ${BACKUP_TIMESTAMP}
else
    echo "FAILURE $BACKUP_NAME: $output"
fi
exit $rc

