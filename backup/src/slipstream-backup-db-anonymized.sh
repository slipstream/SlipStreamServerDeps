#!/bin/bash

DB_PATH='/opt/slipstream/SlipStreamDB/'
CONFIG='/etc/slipstream/slipstream-backup.conf'

HSQLDB_PATH='/opt/hsqldb/lib/hsqldb.jar'
SQLTOOL_PATH='/opt/hsqldb/lib/sqltool.jar'

SQL_ANONYMIZE_FILE='anonymize.sql'

source $CONFIG

AMAZON_BUCKET=${AMAZON_BUCKET_ANONYMIZED:?"Define Amazon S3 anonymize bucket in $CONFIG."}
SS_HOSTNAME=${SS_HOSTNAME:?"Define the host IP/hostname in $CONFIG.

TIMESTAMP=`date --utc "+%Y-%m-%dT%H%MZ"`
CUR_DIR=`pwd`
BUNDLE_NAME="/tmp/slipstream.backup.anonymized.${SS_HOSTNAME}.${TIMESTAMP}"
BUNDLE=/tmp/$BUNDLE_NAME

mkdir $BUNDLE
cd $BUNDLE
cp -R $DB_PATH/* .

java -cp $HSQLDB_PATH org.hsqldb.server.Server --database.0 file:slipstreamdb --dbname.0 slipstream_ano --address 127.0.0.1 --port 9999 &
DB_PID=$!

java -cp $HSQLDB_PATH -jar $SQLTOOL_PATH --inlineRc=url=jdbc:hsqldb:hsql://localhost:9999/slipstream_ano,user=sa,password= --autoCommit $SQL_ANONYMIZE_FILE || echo 'Error during anonymization'

kill -9 $DB_PID

BACKUP="${AMAZON_BUCKET}/${BUNDLE_NAME}"

output=$(/opt/slipstream/backup/s3curl.pl --id sixsq --put $BUNDLE -- $BACKUP 2>&1)
[ "$?" -eq "0" ] && \
    echo "SlipStream Anonymized Backup Successful. $BACKUP" || \
    echo "FAILURE $BACKUP: $output"

cd $CUR_DIR

rm -Rf $BUNDLE

exit 0

