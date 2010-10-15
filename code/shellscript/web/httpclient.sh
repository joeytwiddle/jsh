#!/bin/sh
if [ ! "$*" ] || [ "$1" = --help ]
then
	echo "http_do [ -post ] <url>"
	exit 1
fi

METHOD=GET
if [ "$1" = -post ]
then METHOD=POST
fi

URL="$1"

HOST=`echo "$URL" | afterfirst :// | beforefirst /`
PORT=`echo "$HOST" | afterfirst :`
if [ "$PORT" = "" ] || [ "$PORT" = "$HOST" ]
then PORT=80
else
	HOST=`echo "$HOST" | beforefirst :`
fi

(
echo "$METHOD $URL HTTP/1.0"
## TODO: ## Headers / Post ...
# if [ "$METHOD" = POST ]
# then
	# cat | cgiencode | undoencodingonfirst=sign
# fi
echo
sleep 5
) |

telnet $HOST $PORT
