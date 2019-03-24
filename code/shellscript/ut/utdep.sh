#!/bin/bash
UTDEP=`which utdep.pl`
[ "$UTDEP" ] || . errorexit "utdep requires utdep.pl"

if [ "$*" = "" ]
then
	echo
	echo "utdep [-D] <files>... <utdep.pl_options>..."
	echo
	echo "utdep -F <filename>   Shows the folder the file should go to"
	echo
	echo "  The first incarnation is a wrapper for utdep.pl.  If -D is specified and"
	echo "  \$HOME/.utdep/ignore_packages.list is present, only custom default packages"
	echo "  are shown in the output."
	echo
	# echo "utdep.pl options:"
	# echo
	# "$UTDEP"
	echo "To see utdep.pl_options, run utdep.pl"
	echo
	exit 0
fi

if [ "$1" = -F ]
then
	FILE="$2"
	FILETYPE=`echo "$FILE" | afterlast "\." | tolowercase`
	TARGET="Unknown"
	case "$FILETYPE" in
		unr) TARGET="Maps" ;;
		uax) TARGET="Sounds" ;;
		umx) TARGET="Music" ;;
		unr) TARGET="Maps" ;;
		utx) TARGET="Textures" ;;
		u|int|ini|so) TARGET="System" ;;
		*) jshwarn "No target for $FILETYPE ($1)"
	esac
	echo "$TARGET"
	exit
fi

if [ "$1" = -D ]
then
	shift

	# IGNORE_REGEXP="\(`cat "$HOME"/.utdep/ignore_packages.list | sed 's+$+\\\\|+' | tr -d '\n'`\)"
	IGNORE_REGEXP=`
	if [ -f "$HOME"/.utdep/ignore_packages.list ]
	then
		PART=""
		echo -n "\("
		cat "$HOME"/.utdep/ignore_packages.list |
		while read PACKAGE
		do echo -n "$PART\`toregexp "$PACKAGE"\`" ; PART="\|"
		done
		echo -n "\)"
	fi
	`
fi

"$UTDEP" "$@" |

if [ "$IGNORE_REGEXP" ]
then grep -v -i "$IGNORE_REGEXP"
else cat
fi

