#!/bin/bash


#docker-machine ssh $MAIN_SERVER curl -s -XPUT -d {"host":"boot","action":"boot"} $URL_END_POINT

function consul_curl_prev(){
    # end point: http://$CONSUL_IP:8500/v1/kv/cloud
    MAIN_SERVER=f1
    consul_token="lodGXy8qYan9rCRITiAQDw=="


    PIP_CHECK=no
    while [ $PIP_CHECK != "ok" ]; do
    PIP_MAIN=$(tugboat info -n $MAIN_SERVER |grep Private | sed 's/[\t ]\+/\t/g' | cut -f3)
    echo $PIP_MAIN | egrep "^(([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$" > /dev/null && PIP_CHECK=ok
    done
    # echo "$MAIN_SERVER (PIP):$PIP_MAIN"
}


function consul_deregister_service(){
    consul_curl_prev
    URL_END_POINT=http://$PIP_MAIN:8500/v1/agent/check/deregister/$1?token=$consul_token
    echo $URL_END_POINT
    docker-machine ssh $MAIN_SERVER curl -s -X GET $URL_END_POINT
}



function consul_curl_delete(){
    consul_curl_prev
    URL_END_POINT=http://$PIP_MAIN:8500/v1/kv/$2?token=$consul_token
    docker-machine ssh $MAIN_SERVER curl -s -X DELETE $URL_END_POINT
}


function consul_curl_write(){
    consul_curl_prev
    URL_END_POINT=http://$PIP_MAIN:8500/v1/kv/$2?token=$consul_token
    # echo $URL_END_POINT
    # TEMP=$1
    # echo $TEMP
    # echo ''"${TEMP}"''
    # echo '\{\"host\"\:\"dummy\"\}'
    # docker-machine ssh $MAIN_SERVER curl -s -XPUT -d ''"$1"'' $URL_END_POINT
    docker-machine ssh $MAIN_SERVER curl -s -XPUT -d $1 $URL_END_POINT
    sleep 5

    if [ ! -n $3 ] ; then
        docker-machine ssh $MAIN_SERVER curl -s -XPUT -d '"{\"host\":\"dummy\"}"' $URL_END_POINT
    fi
}

function consul_curl_read(){
    consul_curl_prev
    URL_END_POINT=http://$PIP_MAIN:8500/v1/kv/$1?token=$consul_token
    # echo "$MAIN_SERVER (PIP):$PIP_MAIN"
    # echo "consul reply"
    # echo $URL_END_POINT
    docker-machine ssh $MAIN_SERVER curl -s $URL_END_POINT | jq ".[].Value" -r | base64 -D
}

#curl http://$CONSUL_IP:8500/v1/kv/cloud\?token=$consul_token 2>/dev/null  | jq ".[].Value" -r | base64 -d

function consul_after(){
    consul_curl_write '"{\"host\":\"consul_after\"}"' cloud
}



#galera
function consul_galera_start(){
    consul_curl_write '"{\"host\":\"'"$1"'\",\"action\":\"galera_start\"}"' cloud
}


function consul_galera_initial(){
    consul_curl_write '"{\"host\":\"'"$1"'\",\"action\":\"galera_initial\"}"' cloud
}

function consul_galera_command(){
    consul_curl_write '"{\"host\":\"'"$1"'\",\"action\":\"galera_command\",\"command\":\"'"$2"'\"}"' cloud
}




#nginx
function consul_nginx_reload(){
    consul_curl_write '"{\"host\":\"'"$1"'\",\"action\":\"nginx_reload\"}"' cloud
}

function consul_nginx_command(){
    consul_curl_write '"{\"host\":\"'"$1"'\",\"action\":\"nginx_command\",\"command\":\"'"$2"'\"}"' cloud
}

function consul_boot_fake(){
    consul_curl_write '"{\"host\":\"boot\",\"action\":\"boot\"}"' cloud
}


#laravel
function consul_laravel_command(){
    consul_curl_write '"{\"host\":\"'"$1"'\",\"action\":\"nginx_command\",\"command\":\"'"$2"'\"}"' cloud
}

function consul_laravel_db_seed(){
    consul_curl_write '"{\"host\":\"'"$1"'\",\"action\":\"laravel_db_seed\"}"' cloud
}



function consul_cron_command(){
   consul_curl_write '"{\"host\":\"'"$1"'\",\"action\":\"cron_command\",\"command\":\"'"$2"'\"}"' cloud
}


function consul_cron_db_git_restore(){
    consul_curl_write '"{\"host\":\"'"$1"'\",\"action\":\"cron_db_restore\"}"' cloud
}


function consul_cron_db_git_backup(){
    consul_curl_write '"{\"host\":\"'"$1"'\",\"action\":\"cron_command\",\"command\":\"/bin/bash /backup.sh\"}"' cloud
}


function consul_cron_db_s3_backup(){
    consul_curl_write '"{\"host\":\"'"$1"'\",\"action\":\"cron_command\",\"command\":\"/bin/bash /s3.sh\"}"' cloud
}

function consul_private_ip(){
    consul_curl_write '"{\"host\":\"'"$1"'\",\"action\":\"cron_command\",\"command\":\"/bin/bash /s3.sh\"}"' cloud
}



