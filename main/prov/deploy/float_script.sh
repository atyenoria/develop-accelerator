NODE=(f1 f1ha)
export DO_TOKEN=

docker --tlsverify --tlscacert="/root/.ssh/ca.pem" --tlscert="/root/.ssh/cert.pem" --tlskey="/root/.ssh/key.pem" -H=tcp://128.199.158.47:2376 exec -t app bash -c  "ps -ef|grep -v grep|grep \"nginx: master process\""


if [ ! $? -eq 0 ]; then
    rm -rf /f1_health_ok
    if [ ! -f /f1ha_fail_over ]; then
        python /usr/local/bin/assign-ip 188.166.205.21 12175598
        touch /f1ha_fail_over
        curl -X POST --data-urlencode 'payload={"channel": "#provisioning", "username": "FLOAT | failover to f1ha", "text": "end", "icon_emoji": ":ghost:"}'
    fi
else
    rm -rf /f1ha_fail_over
    if [ ! -f /f1_health_ok ]; then
        python /usr/local/bin/assign-ip 188.166.205.21 12021604
        touch /f1_health_ok
        curl -X POST --data-urlencode 'payload={"channel": "#provisioning", "username": "FLOAT | f1 recovered", "text": "end", "icon_emoji": ":ghost:"}'
    fi
fi


