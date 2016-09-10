
cat << CONSUL | curl -s -XPUT http://**:8500/v1/agent/service/register?token="lodGXy8qYan9rCRITiAQDw==" -d @-
{
  "tags": ["master"],
  "address": "10.130.14.218",
  "port": 80,
  "enableTagOverride": false,
  "name" : "hworks",
  "check": {
    "id": "http",
    "name": "http on port 80",
    "script": "curl -s --head  --request GET https://www.horita-works.com/ | grep \"200 OK\"",
    "interval": "1s",
    "timeout": "1s"
  }
}
CONSUL

