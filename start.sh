#!/bin/bash
echo "Checking if ubuntu..."
if [[ $(lsb_release -d) != *16.04* ]]; then
  echo -e "You are not running Ubuntu 16.04. Installation is cancelled."
  exit 1
fi
echo

if [[ "$ALLWAYSOVERWRITECONFIG" == "1" ]]; then
    echo "Removing old config file..."
    rm $CROPCOINFOLDER/$CONFIG_FILE >/dev/null
fi

echo
echo "Unlocking daemon..."
rm $CROPCOINFOLDER/.lock >/dev/null
echo
echo "Genereting rpc credentials..."
pwgen -s 8 1 > rpcuser
pwgen -s 15 1 > rpcpass
echo
echo "Creating config file..."
echo rpcuser=$(cat rpcuser) >> $CROPCOINFOLDER/$CONFIG_FILE
echo rpcpassword=$(cat rpcpass) >> $CROPCOINFOLDER/$CONFIG_FILE 
echo rpcallowip=127.0.0.1 >> $CROPCOINFOLDER/$CONFIG_FILE 
echo "rpcport=${CROPCOINRPCPORT}" >> $CROPCOINFOLDER/$CONFIG_FILE 
echo listen=1 >> $CROPCOINFOLDER/$CONFIG_FILE 
echo server=1 >> $CROPCOINFOLDER/$CONFIG_FILE 
echo daemon=1 >> $CROPCOINFOLDER/$CONFIG_FILE 
echo "port=${CROPCOINPORT}" >> $CROPCOINFOLDER/$CONFIG_FILE 
echo logtimestamps=1 >> $CROPCOINFOLDER/$CONFIG_FILE
echo maxconnections=256 >> $CROPCOINFOLDER/$CONFIG_FILE
echo

##########################################################################################################
if [[ "$MASTERNODESETUP" == "1" ]]; 
then
    echo "Setup masternode config..."
    echo
    $BINARY_FILE -conf=$CROPCOINFOLDER/$CONFIG_FILE -datadir=$CROPCOINFOLDER && sleep 3
    $BINARY_FILE -conf=$CROPCOINFOLDER/$CONFIG_FILE -datadir=$CROPCOINFOLDER masternode genkey > genkey
    echo "#masternode=1" >> $CROPCOINFOLDER/$CONFIG_FILE
    echo $(curl -s4 icanhazip.com) > ip
    echo "#masternodeaddr=$(cat ip):$CROPCOINPORT" >> $CROPCOINFOLDER/$CONFIG_FILE
    echo "#masternodeprivkey=$(cat genkey)" >> $CROPCOINFOLDER/$CONFIG_FILE
    sed -i 's/daemon=1/daemon=0/' $CROPCOINFOLDER/$CONFIG_FILE
    echo "Stoping $BINARY_FILE"
    echo
    $BINARY_FILE -conf=$CROPCOINFOLDER/$CONFIG_FILE -datadir=$CROPCOINFOLDER stop && sleep 5
    echo
fi
##########################################################################################################

echo "================================================ Current config ================================================================"
cat $CROPCOINFOLDER/$CONFIG_FILE
echo "================================================================================================================================"
echo
echo "Starting $BINARY_FILE -conf=$CROPCOINFOLDER/$CONFIG_FILE -datadir=$CROPCOINFOLDER"
echo
$BINARY_FILE -conf=$CROPCOINFOLDER/$CONFIG_FILE -datadir=$CROPCOINFOLDER && sleep 5
echo
echo "Unlocking wallet..."
$BINARY_FILE walletpassphrase $WALLETPASS 9999999999 && sleep 5
echo
echo "$BINARY_FILE getinfo"
$BINARY_FILE getinfo && sleep 20
echo
echo "$BINARY_FILE getstakinginfo"
$BINARY_FILE getstakinginfo

tail -f $CROPCOINFOLDER/debug.log