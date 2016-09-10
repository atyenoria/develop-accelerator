function GLIP(){
GLIP_CHECK=no
while [ $GLIP_CHECK != "ok" ]; do
GLIP=$(dig +short myip.opendns.com @resolver1.opendns.com)
echo $GLIP  | egrep "^(([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$" > /dev/null && GLIP_CHECK=ok
done
}

function PIP_GET(){
PIP=$(curl -s http://169.254.169.254/metadata/v1/interfaces/private/0/ipv4/address)
}


NGINX_CONF_OUTPUT="/etc/nginx/sites-available/sites-proxy/prod-app.conf"

PIP_GET
CONSUL_IP=$PIP
#eliminate reverse proxy
sed -i -e "/$PIP/c\ " $NGINX_CONF_OUTPUT
cat $NGINX_CONF_OUTPUT
nginx -s reload || echo "nginx erro occured!!"