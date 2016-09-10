#!/bin/sh
FILE1=/etc/nginx/nginx.conf
FILE2=/etc/nginx/sites-available/test.conf

FILE3=/usr/local/etc/php-fpm.conf
FILE4=/usr/local/etc/php/conf.d/php.ini



INTERVAL=1
COMMAND1="nginx -c /etc/nginx/nginx.conf"
COMMAND2="php-fpm -c /usr/local/etc/php-fpm.conf"
MAIN1=nginx
MAIN2=php

# PRE2=python

for x in `ps -ef | grep $MAIN1 | grep -v grep|awk '{print $2}'|sed -n $1p`;
do
sudo kill -9 $x
echo $x
done

for x in `ps -ef | grep $MAIN2 | grep -v grep|awk '{print $2}'|sed -n $1p`;
do
sudo kill -9 $x
echo $x
done


php-fpm -c /usr/local/etc/php-fpm.conf &
nginx -c /etc/nginx/nginx.conf &






last1=`ls --full-time $FILE1 | awk '{print $6"-"$7}'`
last2=`ls --full-time $FILE2 | awk '{print $6"-"$7}'`

last3=`ls --full-time $FILE3 | awk '{print $6"-"$7}'`
last4=`ls --full-time $FILE4 | awk '{print $6"-"$7}'`






while true; do

sleep $INTERVAL
current1=`ls --full-time $FILE1 | awk '{print $6"-"$7}'`
current2=`ls --full-time $FILE2 | awk '{print $6"-"$7}'`

current3=`ls --full-time $FILE3 | awk '{print $6"-"$7}'`
current4=`ls --full-time $FILE4 | awk '{print $6"-"$7}'`

if [ $last1 != $current1 ] ; then
    last1=$current1
    for x in `ps -ef | grep $MAIN1 | grep -v grep|awk '{print $2}'|sed -n $1p`;
    do
    sudo kill -9 $x > /dev/null
    done

    sleep 0.15
    echo -n ".............."
    eval $COMMAND1 &
fi


if [ $last2 != $current2 ] ; then
    last2=$current2
    for x in `ps -ef | grep $MAIN1 | grep -v grep|awk '{print $2}'|sed -n $1p`;
    do
    sudo kill -9 $x  > /dev/null
    done

    sleep 0.15
    echo -n ".............."
    eval $COMMAND1 &
fi


if [ $last3 != $current3 ] ; then
    last3=$current3

    # for x in `ps -ef | grep $MAIN1 | grep -v grep|awk '{print $2}'|sed -n $1p`;
    # do
    # sudo kill -9 $x > /dev/null
    # done
    # eval $COMMAND1 &


    for x in `ps -ef | grep $MAIN2 | grep -v grep|awk '{print $2}'|sed -n $1p`;
    do
    sudo kill -9 $x > /dev/null
    done
    eval $COMMAND2 &


    sleep 0.15
    echo -n ".............."
fi


if [ $last4 != $current4 ] ; then
    last4=$current4

    # for x in `ps -ef | grep $MAIN1 | grep -v grep|awk '{print $2}'|sed -n $1p`;
    # do
    # sudo kill -9 $x > /dev/null
    # done
    # eval $COMMAND1 &


    for x in `ps -ef | grep $MAIN2 | grep -v grep|awk '{print $2}'|sed -n $1p`;
    do
    sudo kill -9 $x > /dev/null
    done
    eval $COMMAND2 &


    sleep 0.15
    echo -n ".............."
fi




done