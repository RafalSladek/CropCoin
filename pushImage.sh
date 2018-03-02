#!/bin/bash
echo "You should be logged in dockerhub before run this script"
echo 
tag=base
docker push rafalsladek/cropcoin-masternode:$tag

tag=latest
docker push rafalsladek/cropcoin-masternode:$tag