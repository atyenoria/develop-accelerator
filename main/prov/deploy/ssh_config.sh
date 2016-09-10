NODE=($@)
SSH_SERVER=sakura
FILE_PATH=prov/deploy

: > $FILE_PATH/ssh_config


cat << EOS >> $FILE_PATH/ssh_config
Host *
StrictHostKeyChecking no
EOS


for i in ${NODE[@]}; do


cat << EOS >> $FILE_PATH/ssh_config

Host $i
Hostname $(docker-machine ip $i)
Port 22
User core
IdentityFile /root/.ssh/${i}_id_rsa

EOS

done


docker-machine scp $FILE_PATH/ssh_config sakura:/root/.ssh/config


