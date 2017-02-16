## Create snapshot

### Creation of ES repository for snapshots

This must be done only once.

```
curl -XPUT 'localhost:9200/_snapshot/es_backup?verify=false&pretty=true' -d@es-s3.json
```

`es-s3.json` file is in this folder.

Check with
```
curl -XGET 'http://localhost:9200/_snapshot/es_backup?pretty'
```

This should return:
```
{
  "es_backup" : {
    "type" : "s3",
    "settings" : {
      "bucket" : "slipstream-backup-es",
      "region" : "eu-west"
    }
  }
}
```

### AWS S3
Bucket on AWS S3 called `slipstream-backup-es` should be manually created in advance.

## Restore from snapshot

### Check available snapshots

To list the available snapshots:
```
curl 'localhost:9200/_cat/snapshots/es_backup?v'
```

### Restore

To restore from a snapshot (adapt the date parameter):
```
/opt/slipstream/backup/slipstream-es-restore-from-backup.sh 2016-09-19T1032Z
```
