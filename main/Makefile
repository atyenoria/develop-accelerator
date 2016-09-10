NODE_MAIN := f1
NODE_SLAVE := f2 f3
NODE_DOWN :=
NODE_EFK :=
NODE_SCALE :=
NODE_MAIN_HA :=
NODE_BUNDLE := ${NODE_MAIN} ${NODE_SCALE} ${NODE_SLAVE} ${NODE_MAIN_HA} ${NODE_EFK}


NODE_TEST := f1 f2 f3
NODE_BENCH_MAIN := b1
NODE_BENCH_SLAVE := b2 b3 b4 b5 b6 b7 b8 b9


m:
	sleep 200

####main
boot: before_boot iptables_boot consul_registrator_boot hosts_add run_boot settlement_boot terraform_boot kibana_register test
	terminal-notifier -message "END|make boot ${NODE}" -title "Digital Ocean" -sound Submarine

recover: before_boot iptables_boot consul_registrator_boot hosts_add run_recover settlement_boot test
	terminal-notifier -message "END|make boot ${NODE}" -title "Digital Ocean" -sound Submarine


####etc
test:
	NODE_MAIN="${NODE_MAIN}" NODE_SLAVE="${NODE_SLAVE}" bats prov/test.bats
ssh_mysql:
	source prov/utility.sh && ssh_mysql ${NODE_SLAVE}
list:
	cat Makefile
consul_health_check:
	bash prov/consul-health/consul.sh ${NODE_MAIN}
pip:
	source prov/utility.sh && pip ${NODE_BUNDLE}
kill_all_main:
	source prov/utility.sh && kill_all_main ${NODE_BUNDLE}
net:
	source prov/utility.sh && network_connection &
test_loop:
	source prov/utility.sh && test_loop
server_down:
	source prov/utility.sh && server_down ${NODE_DOWN}





kibana_register:
	source prov/utility.sh && kibana_register ${NODE_EFK}
	cd ../efk && bash conf.sh ${NODE_EFK}
	eval `docker-machine env ${NODE_EFK}` && cd ../efk && docker-compose stop db || echo "no db container"
	eval `docker-machine env ${NODE_EFK}` && cd ../efk && docker-compose stop cron || echo "no cron container"
	eval `docker-machine env ${NODE_EFK}` && cd ../efk && docker-compose stop redis || echo "no redis container"
	eval `docker-machine env ${NODE_EFK}` && cd ../efk && docker-compose stop app || echo "no app container"
	eval `docker-machine env ${NODE_E
	eval `docker-machine env ${NODE_MAIN}` && docker-compose stop app &&  docker-compose up -d app




## deploy
deploy_git:
	bash prov/deploy/ssh_config.sh ${NODE_BUNDLE}
	bash prov/deploy/git.sh ${NODE_MAIN} ${NODE_SLAVE}
deploy_float:
	bash prov/deploy/float.sh ${NODE_MAIN} ${NODE_MAIN_HA}



## boot
before_boot:
	bash prov/boot-before.sh ${NODE_BUNDLE}
disable_update:
	bash firewall/disable_update.sh ${NODE_BUNDLE}
	terminal-notifier -message " FINISH | make disable_update" -title "Digital Ocean" -sound Submarine
iptables_boot: deploy_git
	bash firewall/iptables.sh ${NODE_BUNDLE}
	terminal-notifier -message " FINISH | make iptables_boot" -title "Digital Ocean" -sound Submarine
consul_registrator_boot:
	bash prov/boot-after.sh -b ${NODE_MAIN} -m boot ${NODE_BUNDLE}
hosts_add:
	source prov/utility.sh && hosts_add ${NODE_BUNDLE}
run_boot:
	bash prov/boot.sh -b ${NODE_MAIN} -m boot ${NODE_SLAVE}
settlement_boot:
	source prov/utility.sh && settlement ${NODE_SLAVE}
terraform_boot:
	bash prov/terraform/dgo.sh



####bench
bench: before_bench iptables_bench after_bench
	terminal-notifier -message "END|make boot ${NODE_BENCH_MAIN} ${NODE_BENCH_SLAVE}" -title "Digital Ocean" -sound Submarine
before_bench:
	bash prov/boot-before.sh ${NODE_BENCH_MAIN} ${NODE_BENCH_SLAVE}
after_bench:
	bash prov/boot-after.sh -b ${NODE_BENCH_MAIN} -m bench ${NODE_BENCH_SLAVE}
iptables_bench:
	bash firewall/iptables.sh ${NODE_BENCH_MAIN} ${NODE_BENCH_SLAVE}
bench_http:
	source prov/utility.sh && bench_http ${NODE_BENCH_SLAVE}




####scale
scale:
	bash prov/boot-before.sh ${NODE_SCALE}
	bash prov/deploy/ssh_config.sh ${NODE_BUNDLE}
	bash firewall/iptables.sh ${NODE_SCALE}
	bash prov/boot-after.sh -b ${NODE_MAIN} -m scale ${NODE_SCALE}
	source prov/utility.sh && hosts_add ${NODE_SCALE}
	bash prov/boot.sh -b ${NODE_MAIN} -m scale ${NODE_SCALE}
	source prov/utility.sh && prov_after_scale ${NODE_SCALE}
	terminal-notifier -message "END|make scale ${NODE_SCALE}" -title "Digital Ocean" -sound Submarine
prov_after_scale:
	source prov/utility.sh && prov_after_scale ${NODE_SCALE}
consul_registrator_scale:
	bash prov/boot-after.sh -b ${NODE_MAIN} -m boot ${NODE_SCALE}


####repair ...etc
# repair_consul_container:
# 	bash prov/boot-after.sh -m scale ${NODE_SLAVE}
# repair_consul_restart:
# 	source prov/utility.sh && repair_consul_restart ${NODE}
# repair_app:
# 	source prov/utility.sh && repair_app ${NODE_MAIN} ${NODE}
# repair_consul:
# 	source prov/utility.sh && bash prov/boot-after.sh -m boot ${NODE}
# repair_main:
# 	source prov/utility.sh && repair_app ${NODE} ${NODE_MAIN}
# 	source prov/utility.sh && repair_prov ${NODE}
# 	source prov/utility.sh && settlement ${NODE}
# run_recover:
# 	bash prov/boot.sh -m recover ${NODE}


# db_restart:
# 	bash prov/boot.sh -m db_restart ${NODE}
# db_boot_all:
# 	source prov/utility.sh && db_boot_all ${NODE}
# db_reset_seed_all:
# 	source prov/utility.sh && db_reset_seed_all ${NODE}
# db_boot_slave:
# 	source prov/utility.sh && db_boot_slave ${NODE}



####deploy

# redis_cluster:
# 	source prov/utility.sh && redis_cluster ${NODE_MAIN} ${NODE}
git_pull_all:
	source prov/utility.sh && git_pull_all ${NODE_SLAVE}
nginx_main:
	source prov/utility.sh && nginx_main
# nginx_config:
# 	source prov/utility.sh &&  eval `docker-machine env ${NODE_MAIN}`  && docker exec -it app cat /etc/nginx/sites-available/sites-sakura/prod-app.conf
# nginx_restart_all:
# 	source prov/utility.sh && nginx_restart_all ${NODE}


# redc1:
# 	redis-cli -c -h f1 -p 4445
# redc2:
# 	redis-cli -c -h f2 -p 4445
# redc3:
# 	redis-cli -c -h f3 -p 4445
# redl:
# 	redis-cli -c -h l1 -p 4447


















# up:
# 	bash prov/boot.sh -m up ${NODE} ${NODE_SCALE}
# dkcob:
# 	bash prov/boot.sh -m dkcob ${NODE} ${NODE_SCALE}
# stop:
# 	bash prov/boot.sh -m stop ${NODE} ${NODE_SCALE}
# remove:
# 	bash prov/boot.sh -m remove ${NODE} ${NODE_SCALE}



# galera:
# 	mysql -h 153.126.191.67 -u root -proot -e "show status like 'wsrep%';"
# galerac:
# 	mysql -h 153.126.191.67 -u root -proot
# boot_private_ip:
# 	source prov/utility.sh && boot_private_ip ${NODE_MAIN} ${NODE}

