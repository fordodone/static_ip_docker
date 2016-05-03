#!/bin/bash

cat >> docker-compose-full-slash-24.yml << EOF
## FILE: docker-compose.yml 
## COMPOSE VERSION: docker-compose version 1.7.0, build 0d7bf73

version: "2"
services:

EOF

for i in `seq 2 254`;
do 
cat >> docker-compose-full-slash-24.yml << EOF
  host-172-20-0-$i:
    hostname: host-172-20-0-$i
    container_name: host-172-20-0-$i
    image: alpine:latest
    networks:
      yellow:
        ipv4_address: 172.20.0.$i
    entrypoint: /bin/sleep 3600

EOF
done;

cat >> docker-compose-full-slash-24.yml << EOF
networks:
  purple:
    driver: overlay
    ipam:
      config:
      - subnet:   172.20.0.0/24
EOF
