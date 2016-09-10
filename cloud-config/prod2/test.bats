function setup {
    dns_ip=
    node1="f1"
    node2="f2"
}



function ddns(){
dig +short @$dns_ip -p 53 $1.node.consul
}



function teardown {
echo end
}


@test "node exits" {
    : > test/test.log
    docker-machine env ${node1} || exit 1
    docker-machine env ${node2} || exit 1
}



@test "etcd works" {
docker-machine ssh ${node1} etcdctl member list
}



@test "sakura dns works at node1, node2" {
    eval `docker-machine env ${node1}`
    ip_in_container="`docker run -it atyenoria/consul-base dig +short @${dns_ip} -p 53 ${node1}.node.consul| tr -d "\r"`"
    ip_in_local="`dig +short @${dns_ip} -p 53 ${node1}.node.consul`"
    [ `echo $ip_in_container` = `echo $ip_in_local` ] || echo error

    eval `docker-machine env ${node2}`
    ip_in_container="`docker run -it atyenoria/consul-base dig +short @${dns_ip} -p 53 ${node2}.node.consul| tr -d "\r"`"
    ip_in_local="`dig +short @${dns_ip} -p 53 ${node2}.node.consul`"
    [ `echo $ip_in_container` = `echo $ip_in_local` ] || echo error
}


@test "normal dns works at node 1" {
eval `docker-machine env ${node1}`
docker run -it --dns=$(ddns ${node1}) atyenoria/consul-base ping -c 1 docs.docker.com
}

@test "normal dns works at node 2" {
eval `docker-machine env ${node2}`
docker run -it --dns=$(ddns ${node2}) atyenoria/consul-base ping -c 1 docs.docker.com
}


@test "add A record in node1" {
eval `docker-machine env ${node1}`
docker-machine scp ./test/service.sh ${node1}:/home/core
docker-machine ssh ${node1} docker run -v \`pwd\`:/tmp -e SERVICE_NAME=apple -e DNS_IP=$(ddns ${node1}) --dns=$(ddns ${node1}) atyenoria/consul-base sh /tmp/service.sh
}

@test "add A record in node2" {
eval `docker-machine env ${node2}`
docker-machine scp ./test/service.sh ${node2}:/home/core
docker-machine ssh ${node2} docker run -v \`pwd\`:/tmp -e SERVICE_NAME=apple -e DNS_IP=$(ddns ${node2}) --dns=$(ddns ${node2}) atyenoria/consul-base sh /tmp/service.sh
}



@test "container communication node2 to node1" {
docker-machine scp ./test/comm.sh ${node1}:/home/core
docker-machine ssh ${node1} docker run -d -v \`pwd\`:/tmp -e SERVICE_NAME=test1 -e DNS_IP=$(ddns ${node1}) --dns=$(ddns ${node1}) atyenoria/consul-base sh /tmp/comm.sh
sleep 10
eval `docker-machine env ${node2}`
docker run -it --dns=$(ddns ${node2}) atyenoria/consul-base ping -c 1 test1.skydns.local
}



@test "container communication node1 to node2" {
docker-machine scp ./test/comm.sh ${node2}:/home/core
docker-machine ssh ${node2} docker run -d -v \`pwd\`:/tmp -e SERVICE_NAME=test2 -e DNS_IP=$(ddns ${node2}) --dns=$(ddns ${node2}) atyenoria/consul-base sh /tmp/comm.sh
sleep 20
eval `docker-machine env ${node1}`
docker run -it --dns=$(ddns ${node1}) atyenoria/consul-base ping -c 1 test2.skydns.local
}