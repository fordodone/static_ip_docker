#!/bin/bash

AWS_ACCESS_KEY=XXXXXXXXX
AWS_SECRET_KEY=XXXXXXXXX
VPC=vpc-XXXXXXXX

AMI='ami-840910ee' #ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-20160420.3
ETH='ens3'
TYPE='c4.xlarge'

KEYPATH=/path/to/.ssh/id_rsa

### kvstore
docker-machine create --driver amazonec2 \
  --amazonec2-access-key $AWS_ACCESS_KEY \
  --amazonec2-secret-key $AWS_SECRET_KEY \
  --amazonec2-ami $AMI \
  --amazonec2-region us-east-1 \
  --amazonec2-vpc-id $KEYPATH \
  --amazonec2-zone e \
  --amazonec2-security-group docker-machine \
  --amazonec2-instance-type t2.micro \
  --amazonec2-root-size 8 \
  --amazonec2-ssh-user $USER \
  --amazonec2-ssh-keypath $KEYPATH \
  kvstore

eval $(docker-machine env kvstore)

docker run -d -p "8500:8500" -h "consul" progrium/consul -server -bootstrap

### swarm master and nodes
MASTER='TRUE'
for i in `seq 31 39`
do
  NAME="s$i"
  if [ "${MASTER}" == 'TRUE' ]
  then
    SWARMFLAG='--swarm --swarm-master'
    MASTER='FALSE'
  else
    SWARMFLAG='--swarm'
  fi

(  docker-machine create --driver amazonec2 \
    --amazonec2-access-key $AWS_ACCESS_KEY \
    --amazonec2-secret-key $AWS_SECRET_KEY \
    --amazonec2-ami $AMI \
    --amazonec2-region us-east-1 \
    --amazonec2-vpc-id  $VPC \
    --amazonec2-zone e \
    --amazonec2-security-group docker-machine \
    --amazonec2-instance-type $TYPE \
    --amazonec2-root-size 8 \
    --amazonec2-ssh-user $USER \
    --amazonec2-ssh-keypath $KEYPATH \
    $SWARMFLAG \
    --swarm-discovery="consul://$(docker-machine ip kvstore):8500" \
    --engine-opt="cluster-store=consul://$(docker-machine ip kvstore):8500" \
    --engine-opt="cluster-advertise=${ETH}:2376" \
    $NAME 2>&1 & ) &

sleep 5s

done

