touch /log.query
sh /sample.sh # db migrate

function PIP_GET(){
PIP=$(curl -s http://**/metadata/v1/interfaces/private/0/ipv4/address)
}


if [ -f /local_check/local ]; then
    echo "you are in local"
    mysqld  --init-file=/bootstrap_local.sql --wsrep-new-cluster

else

    echo "search node.consul" > /etc/resolv.conf
    echo "nameserver $DNS_IP" >> /etc/resolv.conf


    echo "you are in cloud"


    PIP_GET
    CONSUL_IP=$PIP
    consul_token="lodGXy8qYan9rCRITiAQDw=="

    EVENT_INPUT="/etc/event_input"
    EVENT_OUTPUT="/etc/event_output"
    echo "update hogekey > {{ key \"/cloud\" }}" > $EVENT_INPUT
    consul-template \
    -consul $CONSUL_IP:8500 \
    -template "$EVENT_INPUT:$EVENT_OUTPUT" \
    -once \
    -token=$consul_token

    consul-template \
    -consul $CONSUL_IP:8500 \
    -template "$EVENT_INPUT:$EVENT_OUTPUT:bash /consul-template.sh" \
    -token=$consul_token

fi