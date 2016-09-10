

###### consul setting
function GLIP(){
GLIP_CHECK=no
while [ $GLIP_CHECK != "ok" ]; do
GLIP=$(dig +short myip.opendns.com @resolver1.opendns.com)
echo $GLIP | egrep "^(([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$" && GLIP_CHECK=ok
done
}


function PIP_GET(){
PIP=$(curl -s http://169.254.169.254/metadata/v1/interfaces/private/0/ipv4/address)
}


consul_token="lodGXy8qYan9rCRITiAQDw=="


# GLIP
PIP_GET
CONSUL_IP=$PIP
HOST_NAME=`dig +short -x $PIP|cut -d "." -f 1`
action=`curl http://$CONSUL_IP:8500/v1/kv/cloud?token=$consul_token 2>/dev/null  | jq ".[].Value" -r | base64 -d | jq .action |tr -d "\""`
command=`curl http://${CONSUL_IP}:8500/v1/kv/cloud\?token=${consul_token} 2>/dev/null  | jq ".[].Value" -r | base64 -d | jq .command |tr -d "\""`
host=`curl http://${CONSUL_IP}:8500/v1/kv/cloud\?token=${consul_token} 2>/dev/null  | jq ".[].Value" -r | base64 -d | jq .host |tr -d "\"" |cut -d "." -f 1`
echo "this_host:$HOST_NAME, action:$action, command:$command, target_host:$host"
######



if [ $host = "all" -o $host = $HOST_NAME ]; then
echo "start action in $HOST_NAME"
case $action in
    nginx_initial )
        echo "action: nginx_initial"
    ;;
    nginx_reload )
        echo "nginx_reload depreciated"
    ;;
    nginx_command )
        echo "action: command"
        command $command || echo error
    ;;
    laravel_db_seed )
        pushd /app/web
          sed -i -e "/APP_ENV/c\APP_ENV=local" .env
          php artisan migrate && php artisan db:seed
          sed -i -e "/APP_ENV/c\APP_ENV=production" .env
        popd
    ;;
    * )
        echo "no much action"
    ;;
esac
else
echo "no much host"
fi