#!/bin/bash
# Bail on errors
set -e
# We shouldn't have unbounded vars
set -u

count_enabled=$($BINARY_FILE -conf=$CROPCOINFOLDER/$CONFIG_FILE -datadir=$CROPCOINFOLDER getinfo |  grep "\"enabled\" : true," | wc -l | tr -d " ")
    
if [[ "$count_enabled"  == "1" ]]; then
    echo "wallet enabled"
    exit 0
fi
exit 1