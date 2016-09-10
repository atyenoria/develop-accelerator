

EFK_SERVER=$1

PIP=$(tugboat info $EFK_SERVER |grep Private | sed 's/[\t ]\+/\t/g' | cut -f3)


sed -i -e "/elasticsearch_url:/c\elasticsearch_url: \"http://$PIP:9200\"" kibana/config/kibana.yml
sed -i -e "/hosts http/c\ hosts http://$PIP:9200" prod-fluentd/fluent.conf








