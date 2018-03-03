#!/bin/bash
tag=latest
docker rm $(docker ps -qa --no-trunc --filter "status=exited")
mkdir -p cropcoin_data >/dev/null 2>&1
currentData="$(pwd)/cropcoin_data"
docker run -it -d -p 17720:17720 -p 17721:17721 -v $currentData:/home/cropcoin/.cropcoin -e WALLETPASS=yFHSrm^6UV3JUhZDcZmh7%vv3Mu@Jt8B  --name cropcoin rafalsladek/cropcoin:latest
