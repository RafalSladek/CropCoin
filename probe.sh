#!/bin/bash
# Bail on errors
set -e
# We shouldn't have unbounded vars
set -u
PATH=/bin:/usr/bin:$PATH

stakinginfo=$($BINARY_FILE -conf=$CROPCOINFOLDER/$CONFIG_FILE -datadir=$CROPCOINFOLDER getstakinginfo)
count_enabled=$(echo $stakinginfo | grep "\"enabled\" : true," | wc -l | tr -d " ")
count_staking=$(echo $stakinginfo | grep "\"staking\" : true," | wc -l | tr -d " ")

if [ "$count_enabled" = "1" ] && [ "$count_staking" = "1" ]; then
    exit 0
else
    exit 1
fi