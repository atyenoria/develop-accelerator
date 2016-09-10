if [ -f /local_check/local ]; then
exit 0
fi

env > /env
chmod 644 /etc/cron.d/crontab
service cron start


function PIP_GET(){
PIP=$(curl -s http://**/metadata/v1/interfaces/private/0/ipv4/address)
}

PIP_GET
CONSUL_IP=$PIP
consul_token=
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
