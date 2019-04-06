#!/bin/bash

if [ ! -d "$1" ]; then
 echo "[ERROR] Expecting docker-compose.yml location, not: $1 "
 exit -1
fi


echo "cronjob running at "$(date)


cd $1

# Update all images:
docker-compose pull
# Let compose update all containers as necessary
docker-compose up -d

# WARNING! This will remove all dangling images.
docker image prune -f
