# setup skydns
sudo systemctl restart flanneld.service
sudo systemctl restart docker.service

sleep 3



PRIVATE_IP=`ip a |grep "scope global eth1"| grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'`
echo $PRIVATE_IP
temp=`etcdctl member list | cut -d' ' -f4|cut -d',' -f2`
temp=`echo $temp| sed -e 's/ /,/g'`
echo $temp




docker rm -f skydns
docker run -d -p ${PRIVATE_IP}:53:53/udp --name skydns -e SKYDNS_DOMAIN=skydns.local -e SKYDNS_NAMESERVERS=8.8.8.8:53,8.8.4.4:53 -e ETCD_MACHINES=${temp} skynetservices/skydns -addr 0.0.0.0:53

