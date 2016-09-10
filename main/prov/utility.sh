#!/bin/bash
source /Users/jima/core/images/laravel/laravel-prod/main/prov/consul-api.sh


function setup(){
NODE_MAIN=f1
NODE_BENCH_MAIN=b1
}



function network_connection(){
    setup
    touch prov/.pid
    while [ -f prov/.pid ]; do
    sleep 10
    curl -s --head  --request GET http://www.yahoo.co.jp/ | grep "HTTP" > /dev/null
    [ $? -ne 0 ] && \
    terminal-notifier -message "ERROR|local mac network connectivity" -title "Digital Ocean" -sound Submarine && \
    /Users/jima/myshell1/wifi_gusto
    done
}


function test_loop(){
    setup
    for i in `seq 1 1000`; do
    make boot
    sleep 120
    make test
    make test
    sleep 120
    done
}


function kill_all_main(){
    setup
    NODE=($@ $NODE_MAIN)
    for i in ${NODE[@]}; do
    docker-machine rm -f $i
    done
}


function hosts_add(){
    setup
    NODE=($@ $NODE_MAIN)
    for i in ${NODE[@]}; do
    ip=`docker-machine ip $i`
    ip_check="no"
    echo $ip | egrep "^(([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$" && ip_check="ok"
    [ $ip_check = "ok" ] && sudo sed -i -e "/$i/c\ $ip  $i" /etc/hosts
    done
}


function server_down(){

    setup

    NODE=($@)
    for i in ${NODE[@]}; do
        eval `docker-machine env $i` && docker exec -it consul consul leave
        sleep 5
        eval `docker-machine env $i` && docker exec -it consul consul force-leave $i
        sleep 5
        eval `docker-machine env $i` && docker stop `docker ps -q`
        sleep 5
        docker-machine rm -f $i
    done

}


function settlement(){
    setup
    NODE=($@)
    SERVER_CRON="$NODE_MAIN"
    SERVER_PROXY="$NODE_MAIN"


    echo " stop database in $SERVER_PROXY "
    # eval `docker-machine env $SERVER_PROXY` && docker-compose stop db

    echo " stop php-fpm in $SERVER_PROXY "
    consul_nginx_command $SERVER_PROXY "supervisorctl stop php"


    NODE=($SERVER_PROXY "${NODE[@]}")
    for i in ${NODE[@]}; do
        if [ $i != $SERVER_CRON ]; then
            echo "stop cron in $SERVER_CRON"
            eval `docker-machine env $i` && docker-compose stop cron
        fi
    done
}


function prov_after_scale(){
    setup
    NODE=($@)
    for i in ${NODE[@]}; do
       eval `docker-machine env $i` && docker-compose stop cron
    done
}



function redis_cluster(){
    setup
    NODE=($@)
    TEMP=()
    for i in ${NODE[@]}; do
        PIP=$(tugboat info -n $i |grep Private | sed 's/[\t ]\+/\t/g' | cut -f3)
        # echo "FLUSHALL" |redis-cli -p 4445 -h $PIP
        # echo "CLUSTER RESET SOFT" |redis-cli -p 4445 -h $PIP

        TEMP+=("$PIP:4445")
        TEMP+=("$PIP:4446")
    done
    echo ${TEMP[@]}



    # /usr/local/bin/redis-trib create --replicas 1 ${TEMP[@]}
    echo ${TEMP[@]}
    # /usr/local/bin/redt create --replicas 1 ${TEMP[@]}
    # /usr/local/bin/redt create --replicas 1 ${TEMP[@]}
    # /usr/local/bin/redt del-node ${TEMP[@]}

}




function db_boot_all(){
    setup
    NODE=($@)
    MAIN_SERVER=sakura
    echo " consul_galera_initial $MAIN_SERVER "
    consul_galera_initial $MAIN_SERVER
    sleep 30
    for i in ${NODE[@]}; do
        echo " consul_galera_start $i "
        consul_galera_start $i
        sleep 30
    done
}


function db_reset_seed_all(){
    setup
    NODE=($@)
    MAIN_SERVER=$NODE_MAIN

    eval `docker-machine env $MAIN_SERVER` && docker rm -f db && docker-compose up -d db
    for i in ${NODE[@]}; do
        eval `docker-machine env $i` && docker rm -f db && docker-compose up -d db
    done

    echo " consul_galera_initial $MAIN_SERVER "
    consul_galera_initial $MAIN_SERVER
    sleep 20
    consul_laravel_db_seed $MAIN_SERVER
    sleep 20

    for i in ${NODE[@]}; do
        consul_galera_start $i
    done

}


function db_boot_slave(){
    setup
    NODE=($@)
    for i in ${NODE[@]}; do
        echo " consul_galera_start $i "
        eval `docker-machine env $i` && docker-compose up -d db
        sleep 10
        consul_galera_start $i
        sleep 10
    done
}


function db_boot_master(){
    setup
    NODE=($1)
    for i in ${NODE[@]}; do
        echo " consul_galera_initial $i "
        eval `docker-machine env $i` && docker-compose up -d db
        sleep 10
        consul_galera_initial $i
        sleep 10
    done
}




function boot_private_ip(){
    setup
    NODE=($@)
    # set node's private ip to dns
    for i in ${NODE[@]}; do

    PIP=$(tugboat info -n $i |grep Private | sed 's/[\t ]\+/\t/g' | cut -f3)
    GLIP=$(tugboat info -n $i |grep IP4 |  sed 's/\s\{1,\}/ /g' | cut -d' ' -f2)

    consul_curl_write $PIP $GLIP
    consul_curl_read $GLIP
    echo "GLIP:$GLIP"
    echo "PIP:$PIP"

    done


}



function repair_consul_restart(){
    setup
    NODE_CONSUL=$NODE_MAIN

    eval `docker-machine env $NODE_CONSUL` && docker restart consul
    sleep 2
    eval `docker-machine env $NODE_CONSUL` && docker restart registrator
    sleep 2

    NODE=($@)
    for i in ${NODE[@]}; do
        eval `docker-machine env $i` && docker restart consul
        sleep 2
        eval `docker-machine env $i` && docker restart registrator
    done
}




function repair_app(){
    setup
    NODE=($@)
    for i in ${NODE[@]}; do
        eval `docker-machine env $i` && docker-compose restart
    done
}


function repair_prov(){
    setup
    NODE=($@)
    SERVER_CRON="$NODE_MAIN"
    SERVER_PROXY="$NODE_MAIN"
    consul_galera_initial $SERVER_PROXY
    sleep 10
    for i in ${NODE[@]}; do
        consul_galera_start $i
    done

    consul_nginx_reload $SERVER_PROXY
}



function pip(){
    setup
    NODE=($NODE_MAIN $@)
    echo $NODE
    for i in ${NODE[@]}; do
        PIP_MAIN=$(tugboat info -n $i |grep Private | sed 's/[\t ]\+/\t/g' | cut -f3)
        echo "$i PIP: $PIP_MAIN"
    done
}


function ssh_mysql(){
    setup
    NODE=($NODE_MAIN $@)
    BASE_PORT=4001
    : > ~/.ssh/known_hosts
    for i in ${NODE[@]}; do
        PIP=$(tugboat info -n $i |grep Private | sed 's/[\t ]\+/\t/g' | cut -f3)

        for n in $(lsof -i -n -P |grep "*:$BASE_PORT"| sed 's/[\t ]\+/\t/g' | cut -f2); do
            kill -9 $n && echo "kill -9 $n"
        done

        ssh core@$i -g -f -N -L $BASE_PORT:localhost:3306 -i ~/.docker/machine/machines/$i/id_rsa
        echo "$i:$PIP mysql_port:$BASE_PORT"
        BASE_PORT=`expr $BASE_PORT + 1`
    done

}




function nginx_main(){
    setup
    SERVER_PROXY="$NODE_MAIN"
    eval `docker-machine env $SERVER_PROXY` && docker-compose stop app && docker-compose build app && docker-compose up -d app
    sleep 10
    consul_nginx_reload $SERVER_PROXY
    consul_nginx_command $SERVER_PROXY "supervisorctl stop php"
}






function nginx_restart_all(){
    setup
    SERVER_PROXY="$NODE_MAIN"
    NODE=($@)

    eval `docker-machine env $SERVER_PROXY` && docker-compose stop app && docker-compose build app && docker-compose up -d app

    for i in ${NODE[@]}; do
       echo "nginx restart on $i"
       eval `docker-machine env $i` && docker-compose stop app && docker-compose build app && docker-compose up -d app
    done

    echo "nginx restart on $SERVER_PROXY"

    sleep 20
    echo "consul_nginx_reload on $SERVER_PROXY"
    consul_nginx_reload $SERVER_PROXY
    consul_nginx_command $SERVER_PROXY "supervisorctl stop php"
}



function git_pull_all(){
    setup
    NODE=($@)
    for i in ${NODE[@]}; do
        echo "git pull on $i"

        eval `docker-machine env $i` && docker exec -it app bash -c \
        "cd /app/web && sudo -u laravel git pull"

        eval `docker-machine env $i` && docker exec -it app bash -c \
        "cd /app/web && sudo -u laravel git checkout --force $BRANCH"

        eval `docker-machine env $i` && docker-compose stop app && docker-compose up -d app
    done
    echo "done"

}



function bench_http(){
    setup
    NODE_BENCH=$NODE_BENCH_MAIN
    TARGET=https://www.horita-works.com/
    COMMAND="boom -c 10 -n 10000 $TARGET"
    # COMMAND="ls -la"
    eval `docker-machine env $NODE_BENCH` && docker exec -it bench consul exec $COMMAND
}


function kibana_register(){

    NODE_EFK=($@)
    echo $NODE_EFK
    PIP=$(tugboat info -n $NODE_EFK |grep Private | sed 's/[\t ]\+/\t/g' | cut -f3)

    consul_curl_write '"{\"host\":\"'"$PIP"'\"}"' kibana write

}





# obey syntax rule!!!!
# function(){
# setup
# }
