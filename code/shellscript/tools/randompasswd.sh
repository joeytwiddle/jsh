#!/bin/bash

# See also: mkpasswd (in whois package)
# See also: pwgen (from pwgen package)

[ -z "$PASSWORD_LENGTH" ] && PASSWORD_LENGTH=$((10 + RANDOM%11))
< /dev/urandom tr -cd '[:alnum:]' | head -c "$PASSWORD_LENGTH" ; echo



echo
for X in `seq 1 10`
do
	for Y in `seq 1 6`
	#do chooserandomline /usr/share/dict/words | tr '\n' ' '
	do cat /usr/share/dict/words | grep -v "'s$" | chooserandomline | tr '\n' ' '
	done
	echo
	echo
done
