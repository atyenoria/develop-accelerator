#container dns
PIP=$(ip a | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')
GIP=$(/sbin/ip route | awk '/default/ { print $3 }')
curl -XDELETE http://$GIP:4001/v2/keys/skydns/local/skydns/nginx1
curl -XPUT http://$GIP:4001/v2/keys/skydns/local/skydns/nginx1 \
    -d value='{"host":"'"$PIP"'"}'
ping nginx1.skydns.local

