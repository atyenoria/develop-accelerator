DNS_IP=
NODE=(b1 b2)


# dns server
eval `docker-machine env sakura` && docker run \
    -d \
    -p "53:53/udp" \
    -p "8500:8500" \
    -h "consul" \
    progrium/consul -server -bootstrap


# skydns provisioning on node
docker-machine scp ./prov/skydns.sh ${NODE[0]}:/home/core
docker-machine scp ./prov/skydns.sh ${NODE[1]}:/home/core
docker-machine ssh ${NODE[0]} sh /home/core/skydns.sh &
docker-machine ssh ${NODE[1]} sh /home/core/skydns.sh




# set node's private ip to dns
for i in ${NODE[@]}; do



PIP=$(tugboat info $i |grep Private | sed 's/[\t ]\+/\t/g' | cut -f3)
curl -X PUT -d \
'{"Datacenter": "dc1", "Node": "'"$i"'", "Address": "'"${PIP}"'"}' \
http://$DNS_IP:8500/v1/catalog/register
dig @$DNS_IP -p 53 ${i}.node.consul ANY


GLIP=$(tugboat info $i |grep IP4 |  sed 's/\s\{1,\}/ /g' | cut -d' ' -f2)

curl -X PUT -d "$PIP" http://$DNS_IP:8500/v1/kv/$GLIP
sample=`curl http://$DNS_IP:8500/v1/kv/$GLIP | jq ".[].Value" -r | base64 -D`
echo "GLIP:$GLIP"
echo "PIP:$sample"

done


