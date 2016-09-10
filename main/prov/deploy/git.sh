NODE=($@)
BRANCH="origin/master-build-ok"
FILE_PATH=prov/deploy
: > $FILE_PATH/deploy_git.sh





cat << EOS >> $FILE_PATH/deploy_git.sh
NODE=($@)
EOS

for i in ${NODE[@]}; do
cat << EOS >> $FILE_PATH/deploy_git.sh
${i}_ip=`docker-machine ip $i`
EOS
done



# git pull script
cat << EOS >> $FILE_PATH/deploy_git.sh

for i in \${NODE[@]}; do
echo "git pull on \$i"

docker \
--tlsverify \
--tlscacert="/root/.ssh/ca.pem" \
--tlscert="/root/.ssh/cert.pem" \
--tlskey="/root/.ssh/key.pem" \
-H=tcp://\$(eval echo \"\\$\${i}_ip\"):2376 \
start app


docker \
--tlsverify \
--tlscacert="/root/.ssh/ca.pem" \
--tlscert="/root/.ssh/cert.pem" \
--tlskey="/root/.ssh/key.pem" \
-H=tcp://\$(eval echo \"\\$\${i}_ip\"):2376 \
exec -t app bash -c "cd /app/web && sudo -u laravel git pull"


docker \
--tlsverify \
--tlscacert="/root/.ssh/ca.pem" \
--tlscert="/root/.ssh/cert.pem" \
--tlskey="/root/.ssh/key.pem" \
-H=tcp://\$(eval echo \"\\$\${i}_ip\"):2376 \
exec -t app bash -c "cd /app/web && sudo -u laravel git checkout --force $BRANCH"


docker \
--tlsverify \
--tlscacert="/root/.ssh/ca.pem" \
--tlscert="/root/.ssh/cert.pem" \
--tlskey="/root/.ssh/key.pem" \
-H=tcp://\$(eval echo \"\\$\${i}_ip\"):2376 \
restart app


done

EOS





docker-machine scp $FILE_PATH/deploy_git.sh sakura:/root/git.sh
docker-machine scp /Users/jima/.docker/machine/certs/ca.pem sakura:/root/.ssh/ca.pem
docker-machine scp /Users/jima/.docker/machine/certs/cert.pem sakura:/root/.ssh/cert.pem
docker-machine scp /Users/jima/.docker/machine/certs/key.pem sakura:/root/.ssh/key.pem






