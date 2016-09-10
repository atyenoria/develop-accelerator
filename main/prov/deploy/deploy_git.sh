NODE=(f1 f2 f3)
f1_ip=
f2_ip=
f3_ip=

for i in ${NODE[@]}; do
echo "git pull on $i"

docker --tlsverify --tlscacert="/root/.ssh/ca.pem" --tlscert="/root/.ssh/cert.pem" --tlskey="/root/.ssh/key.pem" -H=tcp://$(eval echo \"\$${i}_ip\"):2376 start app


docker --tlsverify --tlscacert="/root/.ssh/ca.pem" --tlscert="/root/.ssh/cert.pem" --tlskey="/root/.ssh/key.pem" -H=tcp://$(eval echo \"\$${i}_ip\"):2376 exec -t app bash -c "cd /app/web && sudo -u laravel git pull"


docker --tlsverify --tlscacert="/root/.ssh/ca.pem" --tlscert="/root/.ssh/cert.pem" --tlskey="/root/.ssh/key.pem" -H=tcp://$(eval echo \"\$${i}_ip\"):2376 exec -t app bash -c "cd /app/web && sudo -u laravel git checkout --force origin/master-build-ok"


docker --tlsverify --tlscacert="/root/.ssh/ca.pem" --tlscert="/root/.ssh/cert.pem" --tlskey="/root/.ssh/key.pem" -H=tcp://$(eval echo \"\$${i}_ip\"):2376 restart app


done

