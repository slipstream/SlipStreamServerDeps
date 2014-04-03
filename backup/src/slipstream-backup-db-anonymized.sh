#!/bin/bash

DB_PATH='/opt/slipstream/SlipStreamDB/'
CONFIG='/etc/slipstream/slipstream-backup.conf'
SQL_ANONYMIZE_FILE='/opt/slipstream/backup/anonymize.sql'

HSQLDB_PATH='/opt/hsqldb/lib/hsqldb.jar'
SQLTOOL_PATH='/opt/hsqldb/lib/sqltool.jar'

source $CONFIG

AMAZON_BUCKET=${AMAZON_BUCKET_ANONYMIZED:?"Define Amazon S3 anonymize bucket in $CONFIG."}
SS_HOSTNAME=${SS_HOSTNAME:?"Define the host IP/hostname in $CONFIG."}

LANG=en_US.utf8
TIMESTAMP=`date --utc "+%Y-%m-%dT%H%MZ"`
CUR_DIR=`pwd`
BUNDLE_NAME="slipstream.backup.anonymized.${SS_HOSTNAME}.${TIMESTAMP}"
BUNDLE=/tmp/$BUNDLE_NAME

mkdir $BUNDLE
cd $BUNDLE
cp -R $DB_PATH/* .

java -cp $HSQLDB_PATH org.hsqldb.server.Server --database.0 file:slipstreamdb --dbname.0 slipstream_ano --address 127.0.0.1 --port 9999 &
DB_PID=$!

java -cp $HSQLDB_PATH -jar $SQLTOOL_PATH --inlineRc=url=jdbc:hsqldb:hsql://localhost:9999/slipstream_ano,user=sa,password= --autoCommit $SQL_ANONYMIZE_FILE || echo 'Error during anonymization'

kill $DB_PID
sleep 5
kill -9 $DB_PID 2>/dev/null || true

tar czf ${BUNDLE}.tgz ${BUNDLE}/*

BACKUP="${AMAZON_BUCKET}/${BUNDLE_NAME}"

output=$(/opt/slipstream/backup/s3curl.pl --id sixsq --put $BUNDLE.tgz -- $BACKUP 2>&1)
[ "$?" -eq "0" ] && \
    echo "SlipStream Anonymized Backup Successful. $BACKUP" || \
    echo "FAILURE $BACKUP: $output"

cd $CUR_DIR

rm -Rf $BUNDLE $BUNDLE.tgz

exit 0

