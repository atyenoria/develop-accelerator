uname -a |grep coreos
if `test $? -eq 0` ; then

GLIP=`curl  inet-ip.info 2>/dev/null`
KVIP=`curl  http://$DNS_IP:8500/v1/kv/$GLIP 2>/dev/null | jq ".[].Value" -r | base64 -d`
echo "nameserver $KVIP" > /etc/resolv.conf

CIP=$(ip a | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')
curl -XDELETE http://$KVIP:4001/v2/keys/skydns/local/skydns/$SERVICE_NAME  >/dev/null 2>&1
curl -XPUT http://$KVIP:4001/v2/keys/skydns/local/skydns/$SERVICE_NAME \
-d value='{"host":"'"$CIP"'"}'  >/dev/null 2>&1
dig ${SERVICE_NAME}.skydns.local > /dev/null || exit 1

cat /etc/resolv.conf
echo "SERVICE_NAME: $SERVICE_NAME"

fi

