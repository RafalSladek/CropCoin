FROM ubuntu:latest

RUN apt-get update && apt-get upgrade -y 
RUN apt-get install -y wget
RUN wget -q https://raw.githubusercontent.com/zoldur/CropCoin/master/cropcoin.sh

EXPOSE 17720 17721
VOLUME [/home/cropcoin/.cropcoin]

ENTRYPOINT [ "bash cropcoin.sh " ]