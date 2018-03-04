#!/bin/bash
# Bail on errors
set -e
# We shouldn't have unbounded vars
set -u

echo "Checking if ubuntu..."
if [[ $(lsb_release -d) != *16.04* ]]; then
  echo -e "You are not running Ubuntu 16.04. Installation is cancelled."
  exit 1
fi
echo

if [[ "$ALLWAYSOVERWRITECONFIG" == "1" ]]; then
    echo "Removing old config file..."
    rm -f -- $CROPCOINFOLDER/$CONFIG_FILE >/dev/null
fi

echo
echo "Unlocking daemon..."
rm -f -- $CROPCOINFOLDER/.lock >/dev/null
echo
echo "Creating config file..."
echo rpcuser=$(openssl rand -base64 29 | tr -d "=+/" | cut -c1-10)  >> $CROPCOINFOLDER/$CONFIG_FILE
echo rpcpassword=$(openssl rand -base64 29 | tr -d "=+/" | cut -c1-64) >> $CROPCOINFOLDER/$CONFIG_FILE 
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
$BINARY_FILE -conf=$CROPCOINFOLDER/$CONFIG_FILE -datadir=$CROPCOINFOLDER && echo "connecting to blockchain network... "
echo
sleep 5
UNLOCKED_SEC=20
SLEEP_SEC=$(( $UNLOCKED_SEC / 2 ))
PATH=/bin:/usr/bin:$PATH

lock=1
while [ "$lock" == "1" ]
do
    echo
    echo "$(date -u) unlocking wallet for $UNLOCKED_SEC seconds..."
    $BINARY_FILE -conf=$CROPCOINFOLDER/$CONFIG_FILE -datadir=$CROPCOINFOLDER walletpassphrase $WALLETPASS $UNLOCKED_SEC
    stakinginfo=$($BINARY_FILE -conf=$CROPCOINFOLDER/$CONFIG_FILE -datadir=$CROPCOINFOLDER getstakinginfo)
    count_enabled=$(echo $stakinginfo | grep "\"enabled\" : true," | wc -l | tr -d " ")
    count_staking=$(echo $stakinginfo | grep "\"staking\" : true," | wc -l | tr -d " ")

    if [ "$count_enabled" = "1" ] && [ "$count_staking" = 1 ]; then
        echo "$(date -u) wallet enabled & staking"
    elif [ "$count_enabled" = "1" ] && [ "$count_staking" = 0 ]; then
        echo "$(date -u) wallet enabled & not staking"
    elif [ "$count_enabled" = "0" ] && [ "$count_staking" = 0 ]; then
        echo "$(date -u) wallet not enabled & not staking"
    fi
    sleep $SLEEP_SEC
done
