

###### consul setting
function GLIP(){
GLIP_CHECK=no
while [ $GLIP_CHECK != "ok" ]; do
GLIP=$(dig +short myip.opendns.com @resolver1.opendns.com)
echo $GLIP | egrep "^(([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$" && GLIP_CHECK=ok
done
}

CONSUL_IP=153.126.191.67
consul_token="lodGXy8qYan9rCRITiAQDw=="

function PIP_GET(){
PIP=$(curl -s http://**/metadata/v1/interfaces/private/0/ipv4/address)
}

PIP_GET
CONSUL_IP=$PIP
HOST_NAME=`dig +short -x $PIP|cut -d "." -f 1`
action=`curl http://${CONSUL_IP}:8500/v1/kv/cloud\?token=${consul_token} 2>/dev/null  | jq ".[].Value" -r | base64 -d | jq .action |tr -d "\""`
command=`curl http://${CONSUL_IP}:8500/v1/kv/cloud\?token=${consul_token} 2>/dev/null  | jq ".[].Value" -r | base64 -d | jq .command |tr -d "\""`
host=`curl http://${CONSUL_IP}:8500/v1/kv/cloud\?token=${consul_token} 2>/dev/null  | jq ".[].Value" -r | base64 -d | jq .host |tr -d "\"" |cut -d "." -f 1`
######


if [ $host = "all" -o $host = $HOST_NAME ]; then
echo "start action in $HOST_NAME"
case $action in
    cron_db_restore )
        echo "action: cron_db_restore"
        RESTORE_FROM_DATABASE_NAME=laravel
        RESTORE_TO_DATABASE_NAME=laravel
        RESTORE_GIT_DIR=/laravel/temp
        RESTORE_REPO=git@github.com:HoritaWorks/db-backup.git
        RESTORE_BRANCH=master

        #clean up
        mysql -h $DB_PORT_3306_TCP_ADDR -u root -p${DB_PASSWORD} -e "drop database $RESTORE_TO_DATABASE_NAME;" || echo "no database exits"
        mysql -h $DB_PORT_3306_TCP_ADDR -u root -p${DB_PASSWORD} -e "create database $RESTORE_TO_DATABASE_NAME;" ||  echo "create database error"
        rm -rf $RESTORE_GIT_DIR
        sudo -u laravel git clone -b $RESTORE_BRANCH $RESTORE_REPO $RESTORE_GIT_DIR
        mysql -h $DB_PORT_3306_TCP_ADDR -u root -p${DB_PASSWORD}
        cd $RESTORE_GIT_DIR && mysql -h $DB_PORT_3306_TCP_ADDR -u root -p${DB_PASSWORD} ${RESTORE_TO_DATABASE_NAME} < ${RESTORE_FROM_DATABASE_NAME}.sql
        rm -rf $RESTORE_GIT_DIR
        echo "done \"action: cron_db_restore\""
    ;;
    cron_command )
        echo "action: command"
        command $command || echo error
    ;;
    * )
        echo "no much action"
    ;;
esac

else
echo "no much host"
fi