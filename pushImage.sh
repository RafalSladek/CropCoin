$ cat pushImage.sh
#!/bin/bash
echo "You should be logged in dockerhub before run this script"
echo 
tag=latest
docker tag cropcoin-masternode:$tag rafalsladek/cropcoin-masternode:$tag
docker push rafalsladek/cropcoin-masternode:$tag