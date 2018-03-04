# CropCoin
Shell script to install a [Cropcoin Masternode](https://bitcointalk.org/index.php?topic=2863802.0) on a Linux server running Ubuntu 16.04. Use it on your own risk.  

## How to generate password?
```openssl rand -base64 32 | tr -d "=+/" | cut -c1-64```

## How to start docker container?
1. before you start encrypt your wallet
2. create or select <CROPCOIND_DATA_DIR>
3. copy your wallet.dat file into <CROPCOIND_DATA_DIR>.
4. run this command
```
docker run \
    -it -d \
    -p 17720:17720 \
    -p 17721:17721 \
    -v $(PWD)/<CROPCOIND_DATA_DIR>:/home/cropcoin/.cropcoin \
    -e WALLETPASS=<YOUR_WALLET_PASSWORD>  \
    --name cropcoin-wallet \
    --hostname cropcoin-wallet \
    --restart always \
    rafalsladek/cropcoin:latest
```

***
## Installation for v1.0.0.2 with shel script:  
```
wget -q https://raw.githubusercontent.com/zoldur/CropCoin/master/cropcoin.sh  
bash cropcoin.sh
```
***

## Update from v1.0.0.1 to v1.0.0.2

** Only use this if you previously installed CropCoin v1.0.0.1 using this script **
```
wget -q https://raw.githubusercontent.com/zoldur/CropCoin/master/cropcoin_update.sh
bash cropcoin_update.sh
```

## Desktop wallet setup  


After the MN is up and running, you need to configure the desktop wallet accordingly. Here are the steps:  
1. Open the CropCoin Desktop Wallet.  
2. Go to RECEIVE and create a New Address: **MN1**  
3. Send **2500** CROP to **MN1**.  
4. Wait for 15 confirmations.  
5. Go to **Help -> "Debug Window - Console"**  
6. Type the following command: **masternode outputs**  
7. Go to **Masternodes** tab  
8. Click **Create** and fill the details:  
* Alias: **MN1**  
* Address: **VPS_IP:PORT**  
* Privkey: **Masternode Private Key**  
* TxHash: **First value from Step 6**  
* Output index:  **Second value from Step 6**  
* Reward address: leave blank  
* Reward %: leave blank  
9. Click **OK** to add the masternode  
10. Click **Start All**  

***

## Multiple MN on one VPS:

It is now possible to run multiple **CropCoin** Master Nodes on the same VPS. Each MN will run under a different user you will choose during installation.  

***

## Usage:

For security reasons **CropCoin** is installed under a normal user, usually **cropcoin**, hence you need to **su - cropcoin** before checking:  

```
CROPUSER=cropcoin #replace cropcoin with the MN username you want to check  

su - $CROPUSER
cropcoind masternode status  
cropcoind getinfo
```

Also, if you want to check/start/stop **cropcoin** daemon for a particular MN, run one of the following commands as **root**:

```
CROPUSER=cropcoin  #replace cropcoin with the MN username you want to check  
  
systemctl status $CROPUSER #To check the service is running  
systemctl start $CROPUSER #To start cropcoind service  
systemctl stop $CROPUSER #To stop cropcpoind service  
systemctl is-enabled $CROPUSER #To check cropcoind service is enabled on boot  
```  

***
  
Any donation is highly appreciated  

RafalSladek:

**CROP**: c3HCzXRTNa7U7SCPAZBqdoQZPzEf4MHZPt  
**BTC**: 37c4J4AdM6u4pXQc1SXAAXYGWxDrCR7a34  
**ETH**: 0x69a8f8bE3A6941C842869D10c8484cAC1649d6E3  

Zoldur:

**CROP**: cKH8Gea49ZtNLLV1Q4zcQaFY7K1uQ2ki5s  
**BTC**: 1BzeQ12m4zYaQKqysGNVbQv1taN7qgS8gY  
**ETH**: 0x39d10fe57611c564abc255ffd7e984dc97e9bd6d  
