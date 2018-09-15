#!/bin/bash

if [ ! -d "$1" ]; then
 echo "[ERROR] Expecting docker-compose.yml location, not: $1 "
 exit -1
fi


echo "cronjob running at "$(date)

docker pull linuxserver/jackett


docker stop jackett
docker rm jackett

cd $1
docker-compose up -d
