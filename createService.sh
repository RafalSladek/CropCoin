#!/bin/bash
#set -exi

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

#COIN=arcticcoin
COIN=chaincoin
SERVICEUSER="${COIN}d"
HOME="/home/$SERVICEUSER"
if [[ "$COIN" == "arcticcoin" ]];
then
        FOLDER="$HOME/.arcticcore"
else
        FOLDER="$HOME/.${COIN}"
fi
CONFIG_FILE="${COIN}.conf"
PID_FILE="${SERVICEUSER}.pid"
COINDAEMON="/usr/local/bin/${SERVICEUSER}"
COINCLI="/usr/local/bin/${COIN}-cli"

function create_service() {
  cat << EOF > /etc/systemd/system/$SERVICEUSER.service
[Unit]
Description=$SERVICEUSER service
After=network.target

[Service]
ExecStart=$COINDAEMON -conf=$FOLDER/$CONFIG_FILE -datadir=$FOLDER -pid=$FOLDER/$PID_FILE
ExecStop=$COINCLI -conf=$FOLDER/$CONFIG_FILE -datadir=$FOLDER stop
Restart=always
User=$SERVICEUSER
Group=$SERVICEUSER

[Install]
WantedBy=multi-user.target
EOF

cat /etc/systemd/system/$SERVICEUSER.service
  systemctl disable $SERVICEUSER.service
  systemctl daemon-reload
  sleep 3
  systemctl start $SERVICEUSER.service
  systemctl enable $SERVICEUSER.service >/dev/null 2>&1
  if [[ -z $(pidof $SERVICEUSER) ]]; then
    echo -e "${RED}$SERVICEUSER is not running${NC}, please investigate. You should start by running the following commands as root:"
    echo "systemctl start $SERVICEUSER.service"
   
    echo "less /var/log/syslog"
    exit 1
  fi
  echo "systemctl status $SERVICEUSER.service"
  echo "journalctl -fu $SERVICEUSER.service"
  systemctl status $SERVICEUSER.service
}

create_service