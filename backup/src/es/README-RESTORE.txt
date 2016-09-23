1) To list the available snapshots:
curl 'localhost:9200/_cat/snapshots/es_backup?v'

2) To restore from a snapshot (adapt the date parameter):
/opt/slipstream/backup/slipstream-es-restore-from-backup.sh 2016-09-19T1032Z
