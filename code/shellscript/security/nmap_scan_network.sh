#!/bin/sh

if [ -n "$1" ]
then network="$1"
else network="192.168.1.0" # TODO: Guess from ifconfig / ip
fi

nmap -sn "${network}/24"
