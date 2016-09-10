
while [ true ];
do
echo -n "."
curl -s --head  --request GET http://$APP_DOMAIN | grep "200 OK" && break
[ `docker inspect app | jq '.[].State.Status' | grep exited` ] && exit 1
[ `docker inspect db | jq '.[].State.Status' | grep exited` ] && exit 1
done


