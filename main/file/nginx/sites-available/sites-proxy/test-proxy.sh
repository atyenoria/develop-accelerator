#!/bin/sh
FILE=prod-app-ssl.conf
DIR=sites-proxy
COMMAND1="nginx -s reload"
PROXY_SERVER=f1
last1=`ls -lT $FILE | awk '{print $7"-"$8}'`
while true; do
    sleep 0.5
    current1=`ls -lT $FILE | awk '{print $7"-"$8}'`
    if [ $last1 != $current1 ] ; then
        last1=$current1

        tput setaf 2
        echo -n ".............."
        tput setaf 7

        eval `docker-machine env $PROXY_SERVER` && docker cp $FILE app:/etc/nginx/sites-available/$DIR/$FILE
        eval `docker-machine env $PROXY_SERVER` && docker exec -it app $COMMAND1
    fi
done