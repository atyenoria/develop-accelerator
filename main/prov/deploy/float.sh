NODE=($@)

HUMIDAI=sakura
BRANCH="origin/master-build-ok"
FILE_PATH=prov/deploy/float_script.sh
CRON_FILE_PATH=prov/deploy/crontab

FLOATING_IP=


MAIN=${NODE[0]}
MAIN_HA=${NODE[1]}
MAIN_DROPLET_ID=$(tugboat info -n $MAIN |grep "ID:" |sed 's/[\t ]\+/\t/g' | cut -f2)
MAIN_DROPLET_IP=$(docker-machine ip $MAIN)
HA_DROPLET_ID=$(tugboat info -n $MAIN_HA |grep "ID:" |sed 's/[\t ]\+/\t/g' | cut -f2)

: > $FILE_PATH



cat << EOS >> $FILE_PATH
NODE=($@)
export DO_TOKEN=
EOS


cat << EOS >> $FILE_PATH

docker \
--tlsverify \
--tlscacert="/root/.ssh/ca.pem" \
--tlscert="/root/.ssh/cert.pem" \
--tlskey="/root/.ssh/key.pem" \
-H=tcp://$MAIN_DROPLET_IP:2376 \
exec -t app bash -c  "ps -ef|grep -v grep|grep \"nginx: master process\""


if [ ! \$? -eq 0 ]; then
    rm -rf /${MAIN}_health_ok
    if [ ! -f /${MAIN_HA}_fail_over ]; then
        python /usr/local/bin/assign-ip $FLOATING_IP $HA_DROPLET_ID
        touch /${MAIN_HA}_fail_over
        curl -X POST --data-urlencode 'payload={"channel": "#provisioning", "username": "FLOAT | failover to $MAIN_HA", "text": "end", "icon_emoji": ":ghost:"}'
    fi
else
    rm -rf /${MAIN_HA}_fail_over
    if [ ! -f /${MAIN}_health_ok ]; then
        python /usr/local/bin/assign-ip $FLOATING_IP $MAIN_DROPLET_ID
        touch /${MAIN}_health_ok
        curl -X POST --data-urlencode 'payload={"channel": "#provisioning", "username": "FLOAT | $MAIN recovered", "text": "end", "icon_emoji": ":ghost:"}'
    fi
fi


EOS


docker-machine scp $FILE_PATH $HUMIDAI:/root/float_script.sh
docker-machine scp $CRON_FILE_PATH $HUMIDAI:/etc/cron.d/crontab
docker-machine ssh $HUMIDAI cd /usr/local/bin \&\& sudo curl -LO http://do.co/assign-ip
docker-machine ssh $HUMIDAI pip -v \|\| apt-get -y install python-pip
docker-machine ssh $HUMIDAI pip install requests
docker-machine ssh $HUMIDAI service cron restart



