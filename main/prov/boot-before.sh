NODE=($@)

MEM=1GB
# MEM=2GB
# MEM=4GB
# MEM=8GB


sleep 10
echo "******************** boot-before *******************"
for i in ${NODE[@]}; do
docker-machine rm -f $i
tugboat destroy -n $i -c
docker-machine \
create \
--driver digitalocean \
--digitalocean-access-token  \
--digitalocean-region "sgp1" \
--digitalocean-ssh-user core \
--digitalocean-image coreos-alpha \
--digitalocean-size "$MEM" \
--digitalocean-private-networking \
$i &
done


sleep 120