FROM atyenoria/mariadb-galera-base

ADD sample.sh /

ADD .zshrc /root/.zshrc

COPY mysql /etc/mysql

ADD start.sh /start.sh
ADD consul-template.sh /consul-template.sh

WORKDIR /etc/mysql


