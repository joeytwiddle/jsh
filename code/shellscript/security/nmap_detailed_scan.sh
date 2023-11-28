#!/bin/sh

# Use -Pn to skip ping "discovery"
#
# Use -sS to scan TCP (with SYN)
# Use -sU to scan UDP
#
# To see what is actually running on each port:
# Use -sV for version detection, and -sC for heavier script interrogation

nmap -sV -sC "$@"
