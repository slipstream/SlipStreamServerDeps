#!/bin/sh -x

SNAPSHOT_DATE=${1:?"Snapshot date is required as an argument. List all snapshots with: curl 'localhost:9200/_cat/snapshots/es_backup?v'
"}

set -e

# Close indices before restoring
curl -XPOST localhost:9200/resources-index/_close

set +e
curl -f -XPOST http://localhost:9200/_snapshot/es_backup/es.snapshot.$SNAPSHOT_DATE/_restore
rc=$?
if [[ $rc -eq 0 ]]; then result=successful; else result=failed; fi
set -e

# Reopen indices after restoring
curl -XPOST http://localhost:9200/resources-index/_open

echo "Restore $result."
exit $rc
