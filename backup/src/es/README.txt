
1) Creation of ES repository for snapshots

curl -XPUT 'localhost:9200/_snapshot/es_backup?verify=false&pretty=true' -d@es-s3.json
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

