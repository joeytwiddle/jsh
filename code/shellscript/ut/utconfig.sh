SYSTEMINI="$HOME/.loki/ut/System/UnrealTournament.ini"
USERINI="$HOME/.loki/ut/System/User.ini"

do_replace () {
	INIFILE="$1" ; shift
	# set -x
	cat "$INIFILE" |
	sed "s$1$2g" |
	cat > "$INIFILE".new &&
	cat "$INIFILE".new > "$INIFILE" &&
	rm "$INIFILE".new
	# set +x
}

case "$1" in

	setstartmap)

		STARTMAP="$2"
		STARTMAP="`echo "$STARTMAP" | afterlast / | sed 's\.unr$'`.unr"
		do_replace "$SYSTEMINI" "^LocalMap=.*" "LocalMap=$STARTMAP"

	;;

	setname)

		NAME="$2"
		do_replace "$USERINI" "^Name=.*" "Name=$2"

	;;

	*)

		echo "utconfig startmap <mapname> | <mapfile>"

		[ ! "$1" = --help ] && echo "Don't understand $1" && exit 1
		exit 0

	;;

esac
