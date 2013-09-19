#!/bin/sh -x

BACKUP_FILE=${1:?"Backup tarball is required as an argument."}

service slipstream stop
service hsqldb stop
pkill -9 -f org.hsqldb.server.Server

set -e

SUFFIX=$(date '+%Y-%m-%d_%H:%M:%S')
[ -d /opt/slipstream/SlipStreamDB ] && \
    mv /opt/slipstream/SlipStreamDB /opt/slipstream/SlipStreamDB.$SUFFIX
[ -d /var/tmp/slipstream/reports ] && \
    mv /var/tmp/slipstream/reports /var/tmp/slipstream/reports.$SUFFIX

tar -C / -xvf $BACKUP_FILE

service hsqldb start || true
service slipstream start
