NODE=($@)

FILE_PATH=prov/consul-health/template.sh
HOME_CLOUD=/home/core
PIP_CLOUD=$(tugboat info -n ${NODE[0]} |grep Private | sed 's/[\t ]\+/\t/g' | cut -f3)

APP_DOMAIN=https://www.horita-works.com/

: > $FILE_PATH




cat << EOT >> $FILE_PATH

cat << CONSUL | curl -s -XPUT http://$PIP_CLOUD:8500/v1/agent/service/register?token="lodGXy8qYan9rCRITiAQDw==" -d @-
{
  "tags": ["master"],
  "address": "$PIP_CLOUD",
  "port": 80,
  "enableTagOverride": false,
  "name" : "hworks",
  "check": {
    "id": "http",
    "name": "http on port 80",
    "script": "curl -s --head  --request GET $APP_DOMAIN | grep \"200 OK\"",
    "interval": "1s",
    "timeout": "1s"
  }
}
CONSUL

EOT




docker-machine scp $FILE_PATH ${NODE[0]}:$HOME_CLOUD
docker-machine ssh ${NODE[0]} bash $HOME_CLOUD/template.sh

