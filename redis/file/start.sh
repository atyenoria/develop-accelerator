#!/bin/bash
if [ -f /local_check/local ]; then
echo "you are in local "
/usr/local/bin/redis-server /usr/local/etc/local/redis.conf
else
echo "you are in cloud "
/usr/bin/supervisord -n
fi



