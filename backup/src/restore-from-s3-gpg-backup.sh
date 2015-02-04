#!/bin/bash -x

set -e

# Prerequisites:
# - /opt/slipstream/server/.s3curl should exist and contain valid
# configuration.
# - /root/.gnupg is available and contains valid private key referenced by
# option $4.

BACKUP_URL=${1:?"Provide URL of the backup on S3."}
IP_NEW=${2:?"Provide current IP of the service."}
IP_OLD=${3:?"Provide old IP of the service."}
GPG_ID=${4:-SixSq}
S3CURL_ID=${5:-sixsq}

DB_PATH=/opt/slipstream/SlipStreamDB
DB_FILE_BASE=$DB_PATH/slipstreamdb
SQLTOOL_PATH=/opt/hsqldb/lib/sqltool.jar

BACKUP_FILE=backup.gpg
BACKUP_TARBALL=backup.tar

function on_trap() {
    rm -f ${BACKUP_TARBALL} ${BACKUP_FILE}
}

trap 'on_trap' EXIT

[ -f ~/.s3curl ] || cp /opt/slipstream/server/.s3curl ~/

echo "::: Downloading backup from S3."
/opt/slipstream/backup/s3curl.pl --id ${S3CURL_ID} -- \
    -f -o ${BACKUP_FILE} ${BACKUP_URL}

echo "::: Stopping services and creating local DB backup."
service slipstream stop || true
service hsqldb stop || true
/usr/sbin/ss-db-shutdown || true
LOCAL_BACKUP=/opt/slipstream/SlipStreamDB.$(date +%s)
cp -rp /opt/slipstream/SlipStreamDB $LOCAL_BACKUP
rm -rf /opt/slipstream/SlipStreamDB/*

echo "::: Decrypting the backup."
gpg -r ${GPG_ID} --output ${BACKUP_TARBALL} --decrypt ${BACKUP_FILE}

echo "::: Applying the backup."
tar -C / -xf ${BACKUP_TARBALL}

echo "::: Checkpoint the backup."
time java -jar $SQLTOOL_PATH --inlineRc=url=jdbc:hsqldb:file:${DB_FILE_BASE},user=sa,password= \
        --autoCommit --sql 'CHECKPOINT;'

echo "::: Applying IP update for service configuration."
if [ "$IP_NEW" != "$IP_OLD" ] ; then
    sed -i -e "s/${IP_OLD}\|bb2.sixsq.com/${IP_NEW}/g" ${DB_FILE_BASE}.script
fi

echo "::: Starting services."
service hsqldb start || true
service slipstream start

echo "::: Local DB backup was saved in $LOCAL_BACKUP"
echo "::: Done."

