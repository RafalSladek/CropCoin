FROM ubuntu:latest
WORKDIR /root

EXPOSE 17720 17721
VOLUME [/home/cropcoin/.cropcoin]
ENV DEBIAN_FRONTEND noninteractive
ENV TERM dumb

ENV TMP_FOLDER "/usr/local/src/"
ENV CONFIG_FILE "cropcoin.conf"
ENV BINARY_FILE "/usr/local/bin/cropcoind"
ENV CROP_REPO "https://github.com/Cropdev/CropDev.git"
ENV RED '\033[0;31m'
ENV GREEN '\033[0;32m'
ENV NC '\033[0m'
ENV CROPCOINPORT 17720
ENV CROPCOINUSER cropcoin
RUN apt-get update >/dev/null 2>&1
RUN DEBIAN_FRONTEND=noninteractive apt-get -y -qq upgrade >/dev/null 2>&1
RUN apt install -y software-properties-common >/dev/null 2>&1
RUN apt-add-repository -y ppa:bitcoin/bitcoin >/dev/null 2>&1
RUN apt-get update >/dev/null 2>&1

RUN apt install -y make build-essential libtool software-properties-common autoconf libssl-dev libboost-dev libboost-chrono-dev libboost-filesystem-dev \
libboost-program-options-dev libboost-system-dev libboost-test-dev libboost-thread-dev sudo automake git pwgen curl libdb4.8-dev \
bsdmainutils libdb4.8++-dev libminiupnpc-dev libgmp3-dev ufw fail2ban \ 
libboost-filesystem-dev libboost-program-options-dev libboost-system-dev libboost-test-dev libboost-thread-dev sudo automake git \
wget pwgen curl libdb4.8-dev bsdmainutils libdb4.8++-dev libminiupnpc-dev libgmp3-dev ufw fail2ban

RUN git clone $CROP_REPO $TMP_FOLDER && \ 
  cd $TMP_FOLDER/src/secp256k1 && \
  ls -al && \
  chmod +x autogen.sh && \
  ./autogen.sh && \
  ./configure --enable-module-recovery && \
  make && \
  ./tests && \
  cd .. && \
  mkdir obj/support && \
  mkdir obj/crypto && \
  make -f makefile.unix && \
  cp -a cropcoind $BINARY_FILE
RUN env
ENV CROPCOINHOME "/home/$CROPCOINUSER"
ENV CROPCOINFOLDER "$CROPCOINHOME/.cropcoin"
      

RUN pwgen -s 15 1 > userpass
RUN useradd -m $CROPCOINUSER  
RUN echo "$CROPCOINUSER:$(cat userpass)" | chpasswd
RUN mkdir -p $CROPCOINFOLDER
RUN chown -R $CROPCOINUSER: $CROPCOINFOLDER >/dev/null
  
RUN pwgen -s 8 1 > rpcuser
RUN pwgen -s 15 1 > rpcpass
RUN [ CROPCOINPORT+1 ] > rpcport
RUN echo rpcuser=$(cat rpcuser) >> $CROPCOINFOLDER/$CONFIG_FILE 
RUN echo rpcpassword=$(cat rpcpass) >> $CROPCOINFOLDER/$CONFIG_FILE 
RUN echo rpcallowip=127.0.0.1 >> $CROPCOINFOLDER/$CONFIG_FILE 
RUN echo rpcport=$(cat rpcport) >> $CROPCOINFOLDER/$CONFIG_FILE 
RUN echo listen=1 >> $CROPCOINFOLDER/$CONFIG_FILE 
RUN echo server=1 >> $CROPCOINFOLDER/$CONFIG_FILE 
RUN echo daemon=1 >> $CROPCOINFOLDER/$CONFIG_FILE 
RUN echo "port=${CROPCOINPORT}" >> $CROPCOINFOLDER/$CONFIG_FILE 

RUN sed -i 's/daemon=1/daemon=0/' $CROPCOINFOLDER/$CONFIG_FILE
RUN echo logtimestamps=1 >> $CROPCOINFOLDER/$CONFIG_FILE
RUN echo maxconnections=256 >> $CROPCOINFOLDER/$CONFIG_FILE

# Masternode
#RUN $(sudo -u $CROPCOINUSER $BINARY_FILE -conf=$CROPCOINFOLDER/$CONFIG_FILE -datadir=$CROPCOINFOLDER masternode genkey) > genkey
#RUN echo masternode=1 >> $CROPCOINFOLDER/$CONFIG_FILE
RUN echo $(curl -s4 icanhazip.com) > ip
#RUN echo masternodeaddr=$(cat ip):$CROPCOINPORT >> $CROPCOINFOLDER/$CONFIG_FILE
#RUN echo masternodeprivkey=$(cat genkey) >> $CROPCOINFOLDER/$CONFIG_FILE

RUN chown -R $CROPCOINUSER: $CROPCOINFOLDER >/dev/null

RUN echo >> /root/$CROPCOINUSER.conf
RUN echo "================================================================================================================================" >> /root/$CROPCOINUSER.conf
RUN echo "Cropcoin Masternode is up and running as user ${GREEN}$CROPCOINUSER${NC} and it is listening on port ${GREEN}$CROPCOINPORT${NC}." >> /root/$CROPCOINUSER.conf
RUN echo "${GREEN}$CROPCOINUSER${NC} password is ${RED}$(cat userpass)${NC}" >> /root/$CROPCOINUSER.conf
RUN echo "Configuration file is: ${RED}$CROPCOINFOLDER/$CONFIG_FILE${NC}" >> /root/$CROPCOINUSER.conf
RUN echo "VPS_IP:Pdocker images -q |xargs docker rmiORT ${RED}$(cat ip):$CROPCOINPORT${NC}" >> /root/$CROPCOINUSER.conf
#RUN echo "MASTERNODE PRIVATEKEY is: ${RED}$CROPCOINKEY${NC}" >> /root/$CROPCOINUSER.conf
RUN echo "================================================================================================================================" >> /root/$CROPCOINUSER.conf

RUN alias start_cropcoin="sudo -u $CROPCOINUSER $BINARY_FILE -conf=$CROPCOINFOLDER/$CONFIG_FILE -datadir=$CROPCOINFOLDER"
CMD ["sudo -u $CROPCOINUSE", "$BINARY_FILE", "-conf=$CROPCOINFOLDER/$CONFIG_FILE",  "-datadir=$CROPCOINFOLDER"]