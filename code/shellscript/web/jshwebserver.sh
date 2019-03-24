#!/bin/bash

# TODO: implement, test
# Spec: Should probably server the current or supplied folder, and everything below it, but nothing above it.
#       If we feel lucky/stupid, we could also optionally run executables if we find them...?
# Major concerns: decoding of incoming URLs ('%20' -> ' ' and all the rest)

# Some suggestions from: http://stackoverflow.com/questions/16640054/minimal-web-server-using-netcat

x=0;
Log=$( echo -n "["$(date "+%F %T %Z")"] $REMOTE_HOST ")$(
while read I[$x] && [ ${#I[$x]} -gt 1 ];do
	echo -n '"'${I[$x]} | sed -e's,.$,",'; let "x = $x + 1";
done ;
); echo $Log >> /var/log/bash_httpd

Body=$(echo -en '<html>Sample html</html>')
echo -en "HTTP/1.0 200 OK\nContent-Type: text/html\nContent-Length: ${#Body}\n\n$Body"


exit

# Additional:
METHOD=$(echo $I[0] |cut -d" " -f0)
REQUEST=$(echo $I[0] |cut -d" " -f1)
HTTP_VERSION=$(echo $I[0] |cut -d" " -f2)
if [ "$METHOD" = "GET" ]; then
	case "$REQUEST" in

		"/")  echo "home page stuff"
			;;
		/who)  echo  "formatted results of who $(who)"
			;;
		/ps)  echo  "Formatted results of ps"
			;;
		*) echo "Page not found header and content"
			;;
	esac
fi


