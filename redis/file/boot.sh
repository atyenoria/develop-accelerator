
for i in `seq 6`; do
    pushd ${i}
    redis-server redis.conf &
    popd
done