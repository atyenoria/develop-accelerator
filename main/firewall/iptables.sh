NODE=($@)


ig=$(dig +short myip.opendns.com @resolver1.opendns.com)
echo $ig
#Add ssh server
#Host *
#StrictHostKeyChecking no

for i in ${NODE[@]}; do
docker-machine scp ~/.docker/machine/machines/${i}/id_rsa sakura:/root/.ssh/${i}_id_rsa
docker-machine ssh sakura rm -rf /root/.ssh/known_hosts
docker-machine ssh sakura ssh $i sudo iptables -A INPUT -p tcp -s $ig -m tcp --dport 22 -j ACCEPT
done



for i in ${NODE[@]}; do

    docker-machine scp firewall/iptables $i:/home/core
    # docker-machine scp firewall/iptables-nat $i:/home/core
    docker-machine ssh $i sudo cp -f iptables /var/lib/iptables/rules-save
    # docker-machine ssh $i sudo cp -f iptables-nat /var/lib/iptables/rules-nat-save
    docker-machine ssh $i sudo systemctl restart iptables-restore.service
    # docker-machine ssh $i sudo systemctl restart docker.service

done


for i in ${NODE[@]}; do
docker-machine ssh sakura ssh $i sudo iptables -A INPUT -p tcp -s $ig -m tcp --dport 22 -j ACCEPT
done