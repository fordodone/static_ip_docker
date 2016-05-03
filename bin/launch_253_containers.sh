#!/bin/bash

docker network create -d overlay --subnet 172.29.0.0/24 yellow

for i in `seq 2 254`; 
do 
  #( docker run -d --net yellow --ip 172.29.0.$i --name host-172-29-0-$i -h host-172-29-0-$i alpine sleep 3600 & ) 
  docker run -d --net yellow --ip 172.29.0.$i --name host-172-29-0-$i -h host-172-29-0-$i alpine sleep 3600 
done

