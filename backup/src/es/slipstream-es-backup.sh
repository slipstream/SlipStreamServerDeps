#!/bin/bash

export LANG=en_US.utf8

set -e

CONFIG=/etc/slipstream/slipstream-es-backup.conf
source $CONFIG

# Close indices
# TODO Check if this is actually needed
curl -XPOST 'localhost:9200/resources-index/_close'

BACKUP_NAME=es.snapshot.${SS_HOSTNAME}.$(date --utc "+%Y-%m-%dT%H%MZ")

curl -XPUT http://localhost:9200/_snapshot/es_backup/$BACKUP_NAME?wait_for_completion=true

# Reopen indices
# TODO Check if this is actually needed
curl -XPOST 'localhost:9200/resources-index/_open'
