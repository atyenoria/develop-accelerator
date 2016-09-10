#!/bin/bash
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
function start_consul_master(){
    # no acl
    echo "************* start_consul_master *************"
    eval `docker-machine env $MAIN_SERVER` && docker rm -f consul
    eval `docker-machine env $MAIN_SERVER` && docker pull progrium/consul
    eval `docker-machine env $MAIN_SERVER` && docker run \
        -d \
            --name consul \
            -p $(docker-machine ip $MAIN_SERVER):8300:8300 \
            -p $(docker-machine ip $MAIN_SERVER):8301:8301 \
            -p $(docker-machine ip $MAIN_SERVER):8301:8301/udp \
            -p $(docker-machine ip $MAIN_SERVER):8302:8302 \
            -p $(docker-machine ip $MAIN_SERVER):8302:8302/udp \
            -p $(docker-machine ip $MAIN_SERVER):8400:8400 \
            -p $(docker-machine ip $MAIN_SERVER):8500:8500 \
            -p 172.17.0.1:53:53/udp \
            -h $MAIN_SERVER \
            -e ATLAS_TOKEN=
            progrium/consul  -server -advertise $(docker-machine ip $MAIN_SERVER) -bootstrap -atlas atyenoria/test -atlas-join
}

function start_datadog(){

    echo "************* start_datadog *************"
    for i in ${NODE[@]}; do
        eval `docker-machine env $i` && docker rm -f datadog
        eval `docker-machine env $i` && docker pull datadog/docker-dd-agent
        eval `docker-machine env $i` && docker run \
                         -d \
                --name datadog \
                -h $i \
                --privileged \
                -v "/var/run/docker.sock:/var/run/docker.sock" \
                -v "/proc/mounts:/host/proc/mounts:ro" \
                -v "/sys/fs/cgroup:/host/sys/fs/cgroup:ro" \
                -e API_KEY= \
                datadog/docker-dd-agent
    done

}



function start_consul_slave(){
    # no acl
    echo "************* start_consul_slave *************"
    for i in ${NODE[@]}; do
        sleep 10
        eval `docker-machine env $i` && docker rm -f consul
        eval `docker-machine env $i` && docker pull progrium/consul
        eval `docker-machine env $i` && docker run \
        -d \
        --name consul \
        -p $(docker-machine ip $i):8300:8300 \
        -p $(docker-machine ip $i):8301:8301 \
        -p $(docker-machine ip $i):8301:8301/udp \
        -p $(docker-machine ip $i):8302:8302 \
        -p $(docker-machine ip $i):8302:8302/udp \
        -p $(docker-machine ip $i):8400:8400 \
        -p $(docker-machine ip $i):8500:8500 \
        -p 172.17.0.1:53:53/udp \
        -h $i \
        -e ATLAS_TOKEN= \
        progrium/consul  -server -advertise $(docker-machine ip $i) -join $(docker-machine ip $MAIN_SERVER)  -atlas atyenoria/test -atlas-join || docker start consul
    done
}
function start_registrator(){
    echo "************* start_registrator *************"

    for i in ${NODE[@]}; do
        PIP=$(tugboat info -n $i |grep Private | sed 's/[\t ]\+/\t/g' | cut -f3)
        sleep 10
        eval `docker-machine env $i` && docker rm -f registrator
        eval `docker-machine env $i` && docker pull gliderlabs/registrator
        eval `docker-machine env $i` && docker run \
        -d \
        -e CONSUL_HTTP_TOKEN="${consul_token}" \
        --name=registrator \
        --volume=/var/run/docker.sock:/tmp/docker.sock \
        -h $i \
        gliderlabs/registrator:latest \
        -ip=$PIP consul://$PIP:8500 || docker start registrator
    done
}




function test_consul_master(){
    echo "************* start_consul_master *************"
    # cd ca && cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=client-server coreos.json | cfssljson -bare coreos
    # cd ..
    PIP_MAIN=$(tugboat info -n $MAIN_SERVER |grep Private | sed 's/[\t ]\+/\t/g' | cut -f3)




    if [ $consul_mode = "normal" ]; then
            eval `docker-machine env $MAIN_SERVER` && docker rm -f consul
            docker-machine scp -r consul/dc1 $MAIN_SERVER:/home/core
            eval `docker-machine env $MAIN_SERVER` && docker pull progrium/consul
            eval `docker-machine env $MAIN_SERVER` && docker run \
            -d \
            --name consul \
            -p $PIP_MAIN:8300:8300 \
            -p $PIP_MAIN:8301:8301 \
            -p $PIP_MAIN:8301:8301/udp \
            -p $PIP_MAIN:8302:8302 \
            -p $PIP_MAIN:8302:8302/udp \
            -p $PIP_MAIN:8400:8400 \
            -p $PIP_MAIN:8500:8500 \
            -p 172.17.0.1:53:53/udp \
            -v /home/core/dc1:/etc/consul-config \
            -h $MAIN_SERVER \
           -e ATLAS_TOKEN= \
             progrium/consul -config-file=/etc/consul-config/conf.json -encrypt=$consul_encrypt -server -advertise $PIP_MAIN  -atlas atyenoria/test -atlas-join -bootstrap

    else
            eval `docker-machine env $MAIN_SERVER` && docker rm -f bench
            docker-machine scp -r consul/dc2 $MAIN_SERVER:/home/core
            eval `docker-machine env $MAIN_SERVER` && docker pull atyenoria/bench
            eval `docker-machine env $MAIN_SERVER` && docker run \
            -d \
            --name bench \
            -p $PIP_MAIN:8300:8300 \
            -p $PIP_MAIN:8301:8301 \
            -p $PIP_MAIN:8301:8301/udp \
            -p $PIP_MAIN:8302:8302 \
            -p $PIP_MAIN:8302:8302/udp \
            -p $PIP_MAIN:8400:8400 \
            -p $PIP_MAIN:8500:8500 \
            -p 172.17.0.1:53:53/udp \
            -v /home/core/dc2:/etc/consul-config \
            -h $MAIN_SERVER \
            -e ACL=$consul_token \
            atyenoria/bench consul agent -ui -server -config-file=/etc/consul-config/conf.json -encrypt=$consul_encrypt -server -advertise $PIP_MAIN -bootstrap -data-dir /go

    fi

}



function test_consul_slave(){
    PIP_MAIN=$(tugboat info -n $MAIN_SERVER |grep Private | sed 's/[\t ]\+/\t/g' | cut -f3)
    echo "************* start_consul_slave *************"
    for i in ${NODE[@]}; do

        PIP=$(tugboat info -n $i |grep Private | sed 's/[\t ]\+/\t/g' | cut -f3)
        PIP_MAIN=$(tugboat info -n $MAIN_SERVER |grep Private | sed 's/[\t ]\+/\t/g' | cut -f3)




        if [ $consul_mode = "normal" ]; then
            eval `docker-machine env $i` && docker rm -f consul
            docker-machine scp -r consul/dc1 $i:/home/core
            eval `docker-machine env $i` && docker pull progrium/consul
            eval `docker-machine env $i` && docker run \
            -d \
            --name consul \
            -p $PIP:8300:8300 \
            -p $PIP:8301:8301 \
            -p $PIP:8301:8301/udp \
            -p $PIP:8302:8302 \
            -p $PIP:8302:8302/udp \
            -p $PIP:8400:8400 \
            -p $PIP:8500:8500 \
            -p 172.17.0.1:53:53/udp \
            -h $i \
            -v /home/core/dc1:/etc/consul-config \
            -e ATLAS_TOKEN= \
             progrium/consul -encrypt=$consul_encrypt -server -advertise $PIP -join $PIP_MAIN  -atlas atyenoria/test -atlas-join -config-file=/etc/consul-config/conf.json
        else
            eval `docker-machine env $i` && docker rm -f bench
            docker-machine scp -r consul/dc2 $i:/home/core
            eval `docker-machine env $i` && docker pull atyenoria/bench
            eval `docker-machine env $i` && docker run \
            -d \
            --name bench \
            -p $PIP:8300:8300 \
            -p $PIP:8301:8301 \
            -p $PIP:8301:8301/udp \
            -p $PIP:8302:8302 \
            -p $PIP:8302:8302/udp \
            -p $PIP:8400:8400 \
            -p $PIP:8500:8500 \
            -p 172.17.0.1:53:53/udp \
            -h $i \
            -v /home/core/dc2:/etc/consul-config \
            -e ACL=$consul_token \
            atyenoria/bench consul agent -ui -server -encrypt=$consul_encrypt -server -advertise $PIP -join $PIP_MAIN -config-file=/etc/consul-config/conf.json -data-dir /go

        fi

     done
}

####################### Don't write any code above this. Arg opt variant error is caused#########################

echo "MODE:$MODE"
NODE=($@)
consul_token="lodGXy8qYan9rCRITiAQDw=="
consul_encrypt="UF0yXYVB8d+bG23IZE+Qxw=="


case $MODE in
  boot )
    echo "******************** boot-after initial ********************"
    MAIN_SERVER=$NODE_MAIN_ARG
    echo "MAIN_SERVER=$NODE_MAIN_ARG"
    consul_mode=normal
    test_consul_master
    test_consul_slave
    NODE=($MAIN_SERVER "${NODE[@]}")
    start_registrator
    start_datadog
    ;;
  scale )
    echo "******************** boot-after scale ********************"
    MAIN_SERVER=$NODE_MAIN_ARG
    consul_mode=normal
    test_consul_slave
    start_registrator
    start_datadog
    ;;
  test )
    echo "******************** boot-after test ********************"
    test_consul_master
    test_consul_slave
    NODE=($MAIN_SERVER "${NODE[@]}")
    start_registrator
    ;;
  bench )
    echo "******************** boot-after test ********************"
    MAIN_SERVER=$NODE_MAIN_ARG
    consul_mode=bench
    test_consul_master
    test_consul_slave
    ;;
  *)
    echo "!!!!! no match MODE error !!!!!"
    ;;
esac


