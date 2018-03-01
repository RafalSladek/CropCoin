#!/bin/bash
tag=latest
#docker rm $(docker ps -qa --no-trunc --filter "status=exited")
docker run -d -p 17720:17720 -p 17721:17721 -v ~/.cropcoin:/home/cropcoin/.cropcoin --name cropcoin rafalsladek/cropcoin-masternode:$tag
docker ps -a
docker logs cropcoin