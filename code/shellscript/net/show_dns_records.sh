#!/bin/sh

# On Windows: dnslook -type=txt "$domain"

for domain
do dig any -q "$domain"
done
