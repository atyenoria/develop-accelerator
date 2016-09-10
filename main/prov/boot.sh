#!/bin/bash
source prov/consul-api.sh
usage_exit() {
        echo "Usage: $0 -m (boot or scale)  items...." 1>&2
        exit 1
}
while getopts "m:b:h" OPT
do
    case $OPT in
        m)
            MODE=${OPTARG}
            ;;
        b)
            NODE_MAIN_ARG=${OPTARG}
            ;;
        h)  usage_exit
            ;;
        \?) usage_exit
            ;;
    esac
done
shift $((OPTIND - 1))

function up_container(){
    echo "********************start up_container ********************"
    date +"%I:%M:%S"
    for i in ${NODE[@]}; do
        echo "********************container $i up ********************"
        consul_boot_fake
        eval `docker-machine env $i` && docker rm -f app db
        sleep 5
        if [ $i = $MAIN_SERVER ]; then
            eval `docker-machine env $i` && docker-compose build
            # eval `docker-machine env $i` && docker pull atyenoria/cron-base
        else
            eval `docker-machine env $i` && docker-compose build app
        fi
        eval `docker-machine env $i` && docker-compose up -d &
    done
}


function check_container_up(){
    echo "************* start check_container_up *************"
    for i in ${NODE[@]}; do
        check=off
        eval `docker-machine env $i` && docker logs app
        if [ $? -ne 0 ]; then
            terminal-notifier -message " ERROR | make boot | $i:app container up.." -title "Digital Ocean" -sound Submarine
            eval `docker-machine env $i` && docker-compose up -d
            echo "..waiting for $i:app container up.."
        fi
    done
    echo "************* containers are all ready *************"
}


function check_http_up(){
    echo "************* start check_http_up *************"
    for i in ${NODE[@]}; do
        GIP=$(docker-machine ip $i)
        echo "..check if $i:$GIP node is ready ..  "
        max_try_temp=0
        max_try=20
        while ! `curl -s --head  --request GET http://$GIP | grep "HTTP" > /dev/null`; do
            sleep 20
            echo "..check if $i:$GIP node is ready ..  "
            max_try_temp=`expr 1 + $max_try_temp`
            if [[ $max_try_temp -gt $max_try  ]]; then
                echo "======================= node http check time out erorr========================="
                max_try_temp=0
                terminal-notifier -message "ERROR | make boot | node http check time out erorr" -title "Digital Ocean" -sound Submarine
                echo "======================= restart container========================="
                # exit 1
            fi
        done
        echo "************* $i:$GIP node is ok *************"
    done
    echo "************* app nginx http status are all ready *************"
}


function start_galera(){
    echo "************* start_galera *************"
    for i in ${NODE[@]}; do
        if [ $i = "$MAIN_SERVER" ]; then
            echo "no action"
        else
            consul_galera_start $i
        fi
    done
}

function start_basic(){

    up_container
    sleep 400
    check_container_up
    check_http_up

}
####################### Don't write any code above this. Arg opt variant error is caused#########################








echo $MODE
NODE=($@)
echo $NODE


case $MODE in
  boot )
    MAIN_SERVER=$NODE_MAIN_ARG
    NODE=($MAIN_SERVER "${NODE[@]}")
    eval `docker-machine env $MAIN_SERVER` && docker exec -it app rm -rf /app/web
    start_basic

    echo "consul_galera_initial $MAIN_SERVER"
    consul_galera_initial $MAIN_SERVER
    sleep 60

    echo "consul_laravel_db_seed $MAIN_SERVER"
    consul_laravel_db_seed $MAIN_SERVER
    sleep 100

    echo "start_galera"
    start_galera
    sleep 30
    echo "************* end of boot *************"
    ;;
  recover )
    MAIN_SERVER=$NODE_MAIN_ARG
    NODE=($MAIN_SERVER "${NODE[@]}")
    eval `docker-machine env $MAIN_SERVER` && docker exec -it app rm -rf /app/web
    start_basic

    consul_galera_initial $MAIN_SERVER
    sleep 60

    consul_cron_db_git_restore $MAIN_SERVER
    sleep 100
    start_galera
    sleep 30
    echo "************* end of boot *************"
    ;;
  scale )
    NODE=("${NODE[@]}")
    start_basic
    start_galera
    echo "************* end of scale *************"
    ;;
  down )
    for i in ${NODE[@]}; do
        eval `docker-machine env $i` && docker-compose up app db &
    done
    ;;
  up )
    NODE=($@)
    for i in ${NODE[@]}; do
        eval `docker-machine env $i` && docker-compose up app db &
    done
    ;;
  dkcob )
    NODE=($@)
    for i in ${NODE[@]}; do
        eval `docker-machine env $i` && docker-compose build && docker up app db &
    done
    ;;
  remove )
    NODE=($@)
    for i in ${NODE[@]}; do
        eval `docker-machine env $i` && docker rm -f app db &
    done
    ;;
  stop )
    NODE=($@)
    for i in ${NODE[@]}; do
        eval `docker-machine env $i` && docker stop app db &
    done
    ;;
  db_restart )
    NODE=($MAIN_SERVER "${NODE[@]}")
    for i in ${NODE[@]}; do
        eval `docker-machine env $i` && docker restart db &
    done
    ;;
  *)
    echo "!!!!! no match MODE error !!!!!"
    ;;
esac




