killall xscreensaver && XSCREENSAVER_WAS_RUNNING=true

# -stop_xscreensaver"
# OPTS="-vo xv" ## my preference: allows me to adjust contrast!
# OPTS="-vo x11" ## for Morphix
# OPTS="-vo sdl" ## good if the machine is slow (but not so pretty)
# OPTS="-vo xv"
## OK all -vo options turned off.  Recommend setting in /etc/mplayer/mplayer.conf or ~/.mplayer.conf
## Audio driver defaults to /etc/mplayer.conf or ~ config.
# OPTS="$OPTS -ao sdl -zoom -idx"
OPTS="$OPTS -zoom -idx"

while true
do
	case "$1" in
		-turbo)
			OPTS="$OPTS -vo sdl"; shift
		;;
		-louder)
			OPTS="$OPTS -af volume=+10dB"; shift
		;;
		-putsubsbelow)
			OPTS="$OPTS -vf expand=0:-140:0:+70 -subpos 100"; shift
		;;
		*)
			break
		;;
	esac
done

verbosely unj mplayer $OPTS "$@"

[ "$XSCREENSAVER_WAS_RUNNING" ] && xscreensaver -no-splash &
