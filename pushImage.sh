#!/bin/bash
echo "You should be logged in dockerhub before run this script"
echo 
tag=base
docker push rafalsladek/cropcoin:$tag

tag=latest
docker push rafalsladek/cropcoin:$tag