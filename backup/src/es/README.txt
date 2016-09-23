

1) Creation of ES repository for snapshots

This must be done only once.

curl -XPUT 'localhost:9200/_snapshot/es_backup?verify=false&pretty=true' -d@es-s3.json

es-s3.json file is in this folder.

check with
curl -XGET 'http://localhost:9200/_snapshot/es_backup?pretty'

This should return:
{
  "es_backup" : {
    "type" : "s3",
    "settings" : {
      "bucket" : "slipstream-backup-es",
      "region" : "eu-west"
    }
  }
}

2) Create a bucket on AWS S3 called slipstream-backup-es
