###### galera setting
function galera_conf(){
echo "you are in $HOST_NAME"
PIP_GET
sed -i -e "/wsrep_node_address/c\wsrep_node_address=$PIP" $MYSQL_CONF_INPUT
sed -i -e "/wsrep_node_name/c\wsrep_node_name=$HOST_NAME" $MYSQL_CONF_INPUT
sed -i -e "/wsrep_cluster_address/c\wsrep_cluster_address=gcomm://$PIP{{range service \"main_db-3306\"}}{{if ne .Address \"$PIP\"}},{{.Address}}{{end}}{{end}}" $MYSQL_CONF_INPUT
cat /etc/mysql/conf.d/galera.tmpl
consul-template \
-once \
-consul $PIP:8500 \
-template "$MYSQL_CONF_INPUT:$MYSQL_CONF_OUTPUT" \
-token=${consul_token}
echo "=========================== after consul-template ==========================="
cat $MYSQL_CONF_OUTPUT
}
MYSQL_CONF_INPUT="/etc/mysql/conf.d/galera.tmpl"
MYSQL_CONF_OUTPUT="/etc/mysql/conf.d/galera.cnf"
######




###### consul setting
function GLIP(){
GLIP_CHECK=no
while [ $GLIP_CHECK != "ok" ]; do
GLIP=$(dig +short myip.opendns.com @resolver1.opendns.com)
echo $GLIP | egrep "^(([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$" && GLIP_CHECK=ok
done
}

function PIP_GET(){
PIP=$(curl -s http://169.254.169.254/metadata/v1/interfaces/private/0/ipv4/address)
}


PIP_GET
CONSUL_IP=$PIP
consul_token="lodGXy8qYan9rCRITiAQDw=="


HOST_NAME=`dig +short -x $PIP|cut -d "." -f 1`
action=`curl http://${CONSUL_IP}:8500/v1/kv/cloud\?token=${consul_token} 2>/dev/null  | jq ".[].Value" -r | base64 -d | jq .action |tr -d "\""`
command=`curl http://${CONSUL_IP}:8500/v1/kv/cloud\?token=${consul_token} 2>/dev/null  | jq ".[].Value" -r | base64 -d | jq .command |tr -d "\""`
host=`curl http://${CONSUL_IP}:8500/v1/kv/cloud\?token=${consul_token} 2>/dev/null  | jq ".[].Value" -r | base64 -d | jq .host |tr -d "\"" |cut -d "." -f 1`
######



if [ $host = "all" -o $host = $HOST_NAME ]; then
echo "start action in $HOST_NAME"
case $action in
    galera_initial )
            echo "action: galera_initial"
            galera_conf
            sed -i -e "/wsrep_cluster_address/c\wsrep_cluster_address=gcomm://$PIP" $MYSQL_CONF_OUTPUT # for initial node
            cat $MYSQL_CONF_OUTPUT
            ps -ef |grep "mysqld" |  grep -v grep || \
            mysqld --wsrep-new-cluster --init-file=/bootstrap_master.sql &
            # service mysql start --init-file=/bootstrap_master.sql
    ;;
    galera_start )
            echo "action: galera_start"
            galera_conf
            ps -ef |grep "mysqld" |  grep -v grep || \
            mysqld --init-file=/bootstrap_master.sql &
            # service mysql start --init-file=/bootstrap_master.sql
    ;;
    galera_command )
        echo "action: command"
        command $command || echo error
    ;;
    * )
            echo "no much action"
    ;;
esac

else
echo "no much host"
fi