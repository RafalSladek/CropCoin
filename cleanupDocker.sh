#!/bin/bash
docker ps -a
docker rm $(docker ps -qa --no-trunc --filter "status=exited")
docker rm $(docker ps -qa --no-trunc --filter "status=created")

docker images | grep "none"
docker rmi $(docker images | grep "none" | awk '/ / { print $3 }')
