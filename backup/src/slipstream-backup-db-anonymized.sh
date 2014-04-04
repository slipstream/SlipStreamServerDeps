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
cd $BUNDLE || exit 1
cp -R $DB_PATH/* .

java -jar $SQLTOOL_PATH --inlineRc=url=jdbc:hsqldb:file:slipstreamdb,user=sa,password= --autoCommit $SQL_ANONYMIZE_FILE || echo 'Error during anonymization'

tar czf ${BUNDLE}.tgz ${BUNDLE}/*

BACKUP="${AMAZON_BUCKET}/${BUNDLE_NAME}"

output=$(/opt/slipstream/backup/s3curl.pl --id sixsq --put $BUNDLE.tgz -- $BACKUP 2>&1)
[ "$?" -eq "0" ] && \
    echo "SlipStream Anonymized Backup Successful. $BACKUP" || \
    echo "FAILURE $BACKUP: $output"

cd $CUR_DIR

rm -Rf $BUNDLE $BUNDLE.tgz

exit 0

