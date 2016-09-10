
NODE=($@)



for i in ${NODE[@]}; do

    docker-machine ssh $i sudo systemctl stop update-engine
    sleep 5
    docker-machine ssh $i sudo systemctl disable update-engine
    sleep 5
    docker-machine ssh $i sudo systemctl stop locksmithd
    sleep 5
    docker-machine ssh $i sudo systemctl disable locksmithd
    sleep 5
    docker-machine ssh $i sudo systemctl daemon-reload

done

