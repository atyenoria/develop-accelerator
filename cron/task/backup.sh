#!/bin/bash


BACKUP_DATABASE_NAME=laravel
BACKUP_GIT_DIR=/laravel/db_backup
BACKUP_REPO=git@github.com:HoritaWorks/db-backup.git
BACKUP_BRANCH=master
BACKUP_VERSION=`date +"%Y%m%d/%H:%M:%S"`



for i in `cat /env`; do
export $i
done


function PIP_GET(){
PIP=$(curl -s http://**/metadata/v1/interfaces/private/0/ipv4/address)
}


consul_token="lodGXy8qYan9rCRITiAQDw=="


# GLIP
PIP_GET
CONSUL_IP=$PIP
HOST_NAME=`dig +short -x $PIP|cut -d "." -f 1`

git config --global user.email
git config --global user.name




rm -rf $BACKUP_GIT_DIR
cd /laravel && sudo -u laravel git clone -b $BACKUP_BRANCH $BACKUP_REPO $BACKUP_GIT_DIR

pushd  $BACKUP_GIT_DIR
  mysqldump -h $DB_PORT_3306_TCP_ADDR -u root -p${DB_PASSWORD} -x $BACKUP_DATABASE_NAME > $BACKUP_DATABASE_NAME.sql
  git add -A
  git commit -m " ${BACKUP_VERSION}  on ${HOST_NAME}"
  sudo -u laravel git push origin $BACKUP_BRANCH
popd

    if [ $? -eq 0 ]; then
        curl -X POST --data-urlencode "payload={\"username\": \"SUCCESS|db-git-backup on ${HOST_NAME}\", \"text\": \"$BACKUP_VERSION\", \"icon_emoji\": \":ghost:\"}"
    else
        curl -X POST --data-urlencode "payload={\"username\": \"ERROR|db-git-backup on ${HOST_NAME}\", \"text\": \"$BACKUP_VERSION\", \"icon_emoji\": \":ghost:\"}"
    fi



echo "done backup.sh"
