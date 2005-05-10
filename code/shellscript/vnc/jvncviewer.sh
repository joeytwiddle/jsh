# The new VNC has broken this script.  But VNC now provides its own jvncviewer.  =)

unj jvncviewer "$@"

exit



if [ "$1" ]
then ADDRESS="$1"
else ADDRESS=":1"
fi

DIR="/stuff/joey/src/deb/vnc-java-3.3.3r2/"
# DIR="/usr/share/vnc-java/"
HOST=`echo "$ADDRESS" | beforelast :`
PORT=`echo "$ADDRESS" | afterlast :`
PORT=`expr 5900 + $PORT || exit`

# cd "$DIR"

# cat "$DIR/page.html" |
cat "$DIR/index.vnc" |
sed 's#<param name="HOST" value=".*">#<param name="HOST" value="'"$HOST"'">#' |
sed 's#<param name="PORT" value="5901">#<param name="PORT" value="'$PORT'">#' |
# sed 's#code="\([^"]*\)"#code="'"$DIR"'/\1"#' |
cat > /tmp/appletvncviewer.html

cp "$DIR"/*.class /tmp

cd /tmp

export CLASSPATH=$CLASSPATH:.

appletviewer appletvncviewer.html
