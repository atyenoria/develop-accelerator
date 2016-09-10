#add container's dns
CIP=$(ip a | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')
curl -XDELETE http://${DNS_IP}:4001/v2/keys/skydns/local/skydns/${SERVICE_NAME}
curl -XPUT http://${DNS_IP}:4001/v2/keys/skydns/local/skydns/${SERVICE_NAME} \
    -d value='{"host":"'"$CIP"'"}'
dig ${SERVICE_NAME}.skydns.local || exit 1
