#!/bin/sh -x

SNAPSHOT_DATE=${1:?"Snapshot date is required as an argument. List all snapshots with: curl 'localhost:9200/_cat/snapshots/es_backup?v'
"}

set -e

# Close indices before restoring
curl -XPOST localhost:9200/resources-index/_close

curl -XPOST http://localhost:9200/_snapshot/es_backup/es.snapshot.$SNAPSHOT_DATE/_restore

# Reopen indices after restoring
curl -XPOST http://localhost:9200/resources-index/_open

echo "Restore done"


