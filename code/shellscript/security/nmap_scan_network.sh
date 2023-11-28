#!/bin/sh

if [ -n "$1" ]
then network="$1"
else network="192.168.1.0" # TODO: Guess from ifconfig / ip
fi

# Search for hosts we can ping
nmap -sn "${network}/24"

# Search for hosts with port 22 open
#nmap -p 22 "${network}/24"
