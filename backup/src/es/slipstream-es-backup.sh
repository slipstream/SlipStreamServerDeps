#!/bin/bash

export LANG=en_US.utf8

set -e

# Note that snapshotname must be lowercase.
BACKUP_NAME=es.snapshot.$HOSTNAME.$(date --utc "+%Y-%m-%dt%H%Mz")

curl -XPUT http://localhost:9200/_snapshot/es_backup/$BACKUP_NAME?wait_for_completion=true

