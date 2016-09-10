default:
	docker build -t atyenoria/fluentd-base . && docker run --rm=true --name=fl -p 24224:24224  atyenoria/fluentd-base
s:
	docker run -it atyenoria/fluentd-base sh
b:
	docker build -t atyenoria/fluentd-base .
r:
	docker run --rm=true --name=test -p 24224:24224  atyenoria/fluentd-base
r1:
	docker run --rm=true --name=test1 -p 24224:24224 -v `pwd`:/fluentd/log atyenoria/fluentd-base
r2:
	docker run --rm=true --name=test2 --log-driver=fluentd --log-opt fluentd-address=192.168.99.100:24224 atyenoria/consul-base echo aaa&& echo aa
r3:
	docker run -p 80:80 --rm=true --name=test3 --log-driver=fluentd --log-opt fluentd-address=192.168.99.100:24224 nginx