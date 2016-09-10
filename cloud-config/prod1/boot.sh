NODE=(b1 b2)
APY_KEY=

URL=`curl -w "\n" "https://discovery.etcd.io/new?size=2"`
sed -i -e "/discovery:/c\    discovery: $URL" cloud-config.yml
tput setaf 3
coreos-cloudinit -validate --from-file=cloud-config.yml || exit 1
tput sgr0


for i in ${NODE[@]}; do
docker-machine rm -f $i
tugboat destroy $i -c
docker-machine \
create \
--driver digitalocean \
--digitalocean-access-token $APY_KEY \
--digitalocean-region "sgp1" \
--digitalocean-ssh-user core \
--digitalocean-image coreos-alpha \
--digitalocean-size "4GB" \
--digitalocean-private-networking \
--digitalocean-userdata cloud-config.yml \
$i &
done

