#!/bin/bash

BACKUP_DATABASE_NAME=laravel
BUCKET=atyenoria
BACKUP_VERSION=`date +"%Y%m%d/%H:%M:%S"`




function PIP_GET(){
PIP=$(curl -s http://**/metadata/v1/interfaces/private/0/ipv4/address)
}
# GLIP
PIP_GET
CONSUL_IP=$PIP
HOST_NAME=`dig +short -x $PIP|cut -d "." -f 1`


for i in `cat /env`; do
export $i
done


rm -rf $BACKUP_DATABASE_NAME.sql
mysqldump -h $DB_PORT_3306_TCP_ADDR -u root -p${DB_PASSWORD} -x $BACKUP_DATABASE_NAME > $BACKUP_DATABASE_NAME.sql && \
s3cmd put -r $BACKUP_DATABASE_NAME.sql s3://$BUCKET

if [ $? -eq 0 ]; then
curl -X POST --data-urlencode "payload={\"username\": \"SUCCESS|db-s3-backup on ${HOST_NAME}\", \"text\": \"$BACKUP_VERSION\", \"icon_emoji\": \":ghost:\"}" **
else
curl -X POST --data-urlencode "payload={\"username\": \"ERROR|db-s3-backup on ${HOST_NAME}\", \"text\": \"$BACKUP_VERSION\", \"icon_emoji\": \":ghost:\"}" **
fi


echo "done s3.sh"