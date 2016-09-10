function db_initial(){
  #clear up database
  mysql -h $MAIN -u root -proot -e "
  drop database sample;
  "
}

function setup {
  echo "setup"
  CONSUL_IP=153.126.191.67
  consul_token="lodGXy8qYan9rCRITiAQDw=="
  MAIN=f1
  CRON_SERVER=f1
  NODE_SLAVE=("${NODE_SLAVE[@]}")
  NODE_MAIN=("${NODE_MAIN[@]}")
  MYSQL_PASS="2Y8A/8Bsar4Ep54AV53Yxw=="
}


function teardown {
  echo end
}


@test "node exits" {
  for i in ${NODE[@]}; do
  docker-machine env $i
  [ $? -eq 0 ]
  done
}


@test "consul registrator container exits" {
  for i in ${NODE[@]}; do
  echo "********check consul of $i ********"
  eval `docker-machine env $i` && docker exec -it consul ls
  [ $? -eq 0 ]

  echo "********check registrator of $i ********"
  eval `docker-machine env $i` && docker exec -it registrator ls
  [ $? -eq 0 ]
  done
}


@test "nginx status" {
  for i in ${NODE[@]}; do
  GIP=`docker-machine ip $i`
  echo "$i $GIP"
  curl -s --head  --request GET http://$GIP | grep "HTTP" > /dev/null
  [ $? -eq 0 ]
  done
}


@test "galera cluster connected" {
  DATE=`date +"%Y:%m:%d:%I:%M:%S"`

  LOG_NAME=test1_$DATE
  : > prov/log/$LOG_NAME

  for i in ${NODE[@]}; do

  echo "************connect galera $i***********" >> prov/log/$LOG_NAME
  PIP=$(tugboat info -n $i |grep Private | sed 's/[\t ]\+/\t/g' | cut -f3)
   eval `docker-machine env $CRON_SERVER` && docker exec -it cron mysql -h $PIP -u root -p${MYSQL_PASS} -e "show status like 'wsrep%';" >> prov/log/$LOG_NAME || terminal-notifier -message " ERROR | make test | $i:galera.." -title "Digital Ocean" -sound Submarine
  [ $? -eq 0 ]
  #mysql -h sakura -u root -proot
  done
}



@test "galera cluster works" {

  db_initial || echo "no db exits"

  DATE=`date +"%Y:%m:%d:%I:%M:%S"`
  LOG_NAME=test2_$DATE
  : > prov/log/$LOG_NAME

  PIP=$(tugboat info -n $CRON_SERVER |grep Private | sed 's/[\t ]\+/\t/g' | cut -f3)
  eval `docker-machine env $CRON_SERVER` && docker exec -it cron \
  mysql -h $PIP -u root -p${MYSQL_PASS} -e "
  create database sample;
  use sample;
  CREATE TABLE CardInfo (
    CardID nchar(6),
    CustomerID nchar(5),
    IssueDate datetime,
    ExpireDate datetime,
    EmployeeID int
  );

  INSERT INTO CardInfo (
    CardID,
    CustomerID,
    IssueDate,
    ExpireDate,
    EmployeeID
  )
  VALUES
  (  'NW0001',
     'ALFKI',
     '2001/4/1',
     '2002/3/31',
     '7'
  );
  " || terminal-notifier -message " ERROR | make test | $i:galera.." -title "Digital Ocean" -sound Submarine


  sleep 0.3
  for i in ${NODE[@]}; do
    PIP=$(tugboat info -n $i |grep Private | sed 's/[\t ]\+/\t/g' | cut -f3)

    eval `docker-machine env $CRON_SERVER` && docker exec -it cron \
    mysql -h $PIP -u root -p${MYSQL_PASS} -e "
    use sample;
    select * from CardInfo;
    " >> prov/log/$LOG_NAME
  done


  #clear up
  PIP=$(tugboat info -n $CRON_SERVER |grep Private | sed 's/[\t ]\+/\t/g' | cut -f3)
  eval `docker-machine env $CRON_SERVER` && docker exec -it cron \
  mysql -h $PIP -u root -p${MYSQL_PASS} -e " drop database sample;"

}



@test "galera cluster have laravel db" {
  for i in ${NODE[@]}; do
  PIP=$(tugboat info -n $i |grep Private | sed 's/[\t ]\+/\t/g' | cut -f3)
  eval `docker-machine env $CRON_SERVER` && docker exec -it cron \
  mysql -h $PIP -u root -p${MYSQL_PASS} -e "
  use laravel;
  "
  done
}




@test "consul api works" {

source /Users/jima/core/images/laravel/laravel-prod/main/prov/consul-api.sh && consul_after | grep true && echo ok
[ $? -eq 0 ]

}



@test "test finish" {
terminal-notifier -message " FINISH | make test" -title "Digital Ocean" -sound Submarine
}

