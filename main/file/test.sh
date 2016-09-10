cat << EOT | curl -XPUT http://sakura:8500/v1/kv/cloud -d @-
{
  "host": "$1",
  "action": "galera_command",
  "command": "$2",
  "demo": "$(date)"
}
EOT