# jsh-ext-depends: killall
# jsh-ext-depends-ignore: expand xscreensaver
# jsh-depends: unj verbosely


## See also: my gentoo version of mplayer has a -stop-xscreensaver option
## TODO: could killall -STOP it, then unhalt it at end.
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
			OPTS="$OPTS -af volume=+20dB"; shift
		;;
		-putsubsbelow)
			OPTS="$OPTS -vf expand=0:-140:0:+70 -subpos 100"; shift
		;;
		*)
			break
		;;
	esac
done

[ "$MPLAYER" ] || MPLAYER=mplayer
verbosely unj $MPLAYER $OPTS "$@"

[ "$XSCREENSAVER_WAS_RUNNING" ] && xscreensaver -no-splash &
