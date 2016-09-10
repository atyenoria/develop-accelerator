#!/bin/bash

function GLIP(){
GLIP_CHECK=no
while [ $GLIP_CHECK != "ok" ]; do
GLIP=$(dig +short myip.opendns.com @resolver1.opendns.com)
echo $GLIP | egrep "^(([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$" && GLIP_CHECK=ok
done
}


function PIP_GET(){
PIP=$(curl -s http://169.254.169.254/metadata/v1/interfaces/private/0/ipv4/address)
}


function initial_setup(){

  volume_mount_depend # if not, composer will not work
  sed -i -e "/zend_extension/c\#zend_extension = \/usr\/local\/lib\/php\/extensions/no-debug-non-zts-20151012\/xdebug.so" /usr/local/etc/php/php.ini # prevent performance degreation

  composer config --global github-oauth.github.com
  chmod 600 /laravel/.ssh/id_rsa1
  chmod 600 /laravel/.ssh/authorized_keys
  chown laravel /laravel/.ssh/authorized_keys
  chown -Rf laravel.laravel /laravel
  chmod -R 700 /laravel/.ssh
  chmod -R 600 /laravel/.ssh/authorized_keys


  if [ ! -d "/app/web" ]; then
    rm -rf /app/web
    chown -Rf laravel.laravel /app
    sudo -u laravel git clone -b master $APP_REPO_URL /app/web
    pushd /app/web
      sudo -u laravel git fetch
      git checkout --force $APP1_BRANCH
      sed -i -e "/APP_ENV/c\APP_ENV=local" .env
      laravel_env
      composer install || composer install || composer install
      if [ -f /local_check/local ]; then
        sed -i -e "/DB_PASSWORD/c\DB_PASSWORD=root" /app/web/.env
        php artisan migrate && php artisan db:seed
      fi
    popd
  fi

}



function laravel_env(){
  sed -i -e "/DB_USERNAME/c\DB_USERNAME=$DB_USERNAME" .env
  sed -i -e "/DB_PASSWORD/c\DB_PASSWORD=$DB_LARAVEL_PASSWORD" .env
  sed -i -e "/DB_HOST/c\DB_HOST=$DB_PORT_3306_TCP_ADDR" .env
  sed -i -e "/APP_KEY/c\APP_KEY=$APP_KEY" .env
}

function volume_mount_depend(){

  rm -rf /usr/local/etc/*
  rm -rf /etc/nginx/*
  rm -rf /etc/supervisor/*
  cp -rf `ls -dA /etc-php/*`  /usr/local/etc
  cp -rf `ls -dA /nginx/*` /etc/nginx
  cp -rf `ls -dA /supervisor/*` /etc/supervisor

}

function laravel_common_setup() {

  pushd /app/web
    sed -i -e "/APP_ENV/c\APP_ENV=$LARAVEL_APP_ENV" .env
    sed -i -e "/APP_DEBUG/c\APP_DEBUG=$APP_LARAVE_DEBUG" .env
    laravel_env
    chown -Rf laravel.laravel /app/*
    chmod -Rf 777 /app/web/storage
  popd

}




initial_setup

if [ -f /local_check/local ]; then
  echo "+++++++++ in local +++++++++"
  # cd /app/web && git checkout --force $APP_LOCAL_BRANCH
  laravel_common_setup

  echo laravel:laravel | /usr/sbin/chpasswd

  sed -i -e "/APP_ENV/c\APP_ENV=local" /app/web/.env
  sed -i -e "/DB_PASSWORD/c\DB_PASSWORD=root" /app/web/.env
  sed -i -e "/APP_DEBUG/c\APP_DEBUG=true" /app/web/.env

  service ssh start &

  touch /app/web/xdebug.log

  sed -i -e "/include \/etc\/nginx\/sites-available/c\include \/etc\/nginx\/sites-available\/sites-local\/*.conf;" /etc/nginx/nginx.conf
  sed -i -e "/#zend_extension/c\zend_extension = \/usr\/local\/lib\/php\/extensions/no-debug-non-zts-20151012\/xdebug.so" /usr/local/etc/php/php.ini

  sed -i -e "/APP_URL/c\APP_URL=http://ld.com" /app/web/.env
  cd /app/web/ && php artisan serve --host=0.0.0.0 --port 4000  &
  sleep 1
  sed -i -e "/APP_URL/c\APP_URL=http://l.com" /app/web/.env


  php-fpm -c /usr/local/etc/php/php-fpm.conf &

  nginx -c /etc/nginx/nginx.conf

else
  #dns setting
  echo "search node.consul" > /etc/resolv.conf
  echo "nameserver $DNS_IP" >> /etc/resolv.conf

  cd /app/web && git checkout --force $APP_CLOUD_BRANCH
  laravel_common_setup
  volume_mount_depend
  sed -i -e "/APP_URL/c\APP_URL=$CLOUD_APP_DOMAIN" /app/web/.env
  sed -i -e "/zend_extension/c\#zend_extension = \/usr\/local\/lib\/php\/extensions/no-debug-non-zts-20151012\/xdebug.so" /usr/local/etc/php/php.ini



  #cloud config
  PIP_GET
  CONSUL_IP=$PIP
  consul_token="lodGXy8qYan9rCRITiAQDw=="
  HOST_NAME=`dig +short -x $PIP`
  proxy=f1
  proxy_ha=f1ha


  if [ "$proxy.node.dc1.consul." = "$HOST_NAME" -o "$proxy_ha.node.dc1.consul." = "$HOST_NAME" ] ; then
    echo "+++++++++ in proxy +++++++++"
    sed -i -e "/include \/etc\/nginx\/sites-available/c\include \/etc/nginx\/sites-available\/sites-proxy/\prod*;" /etc/nginx/nginx.conf
    sed -i -e "/proxy_pass/c\proxy_pass http://$PIP:8500;" /etc/nginx/sites-available/sites-proxy/prod-consul.conf
  else
    #statements
    echo "+++++++++ in backend +++++++++"
    php artisan queue:listen &
    sed -i -e "/include \/etc\/nginx\/sites-available/c\include \/etc/nginx\/sites-available\/sites-backend/\prod*;" /etc/nginx/nginx.conf
  fi



  #normal start
  rm -rf /etc/supervisor/supervisord.conf.org
  supervisord -n -c /etc/supervisor/conf.d/supervisord.conf &


  while [ ! -f /run/nginx.pid ] ; do
    sleep 1
  done



  if [ "$proxy.node.dc1.consul." = "$HOST_NAME" -o "$proxy_ha.node.dc1.consul." = "$HOST_NAME"  ] ; then

    #kibana
    host_kibana=`curl http://${CONSUL_IP}:8500/v1/kv/kibana\?token=${consul_token} 2>/dev/null  | jq ".[].Value" -r | base64 -d | jq .host |tr -d "\""`

    #fluent-hydra
    sed -i -e "/Host = /c\Host = \"$host_kibana\"" /fluent-hydra.toml
    fluent-agent-hydra -c /fluent-hydra.toml &


    #kibana-nginx-proxy
    sed -i -e "/proxy_pass/c\proxy_pass http://$host_kibana:5601;" /etc/nginx/sites-available/sites-proxy/prod-kibana.conf
    NGINX_CONF_INPUT="/etc/nginx/sites-available/sites-proxy/tmpl-app.conf"
    NGINX_CONF_OUTPUT="/etc/nginx/sites-available/sites-proxy/prod-app.conf"
    CONSUL_IP=$PIP
    echo "action: nginx_reload"
    cat $NGINX_CONF_INPUT

    ps -ef |grep "$NGINX_CONF_INPUT" |  grep -v grep || \
    consul-template \
    -consul $CONSUL_IP:8500 \
    -template "$NGINX_CONF_INPUT:$NGINX_CONF_OUTPUT:/bin/bash /nginx_reload.sh" \
    -token=$consul_token &

    supesupervisorctl stop php
  fi


  EVENT_INPUT="/etc/event_input"
  EVENT_OUTPUT="/etc/event_output"
  echo "update hogekey > {{ key \"/cloud\" }}" > $EVENT_INPUT
  consul-template \
  -consul $CONSUL_IP:8500 \
  -template "$EVENT_INPUT:$EVENT_OUTPUT" \
  -once \
  -token=$consul_token


  consul-template \
  -consul $CONSUL_IP:8500 \
  -template "$EVENT_INPUT:$EVENT_OUTPUT:bash /consul-template.sh" \
  -token=$consul_token

fi

