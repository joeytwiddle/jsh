## TODO: move unlinkhome into this script, keeping code in one place.

if [ "$1" = "-diff" ]
then
	shift
	SHOWDIFFS=true
fi

if [ "$1" = --help ]
then
	echo
	echo "linkhome [ -diff ] [ <grep_pattern> ]"
	echo
	echo "  links Joey's rc scripts from $JPATH/code/home to your own homedir $HOME"
	echo
	echo "  Providing a pattern means only files matching that pattern will be linked."
	echo
	echo "  -diff shows the differences between the files when there is a collision"
	echo
	exit 1
fi

GREPBY="$1"

cd "$JPATH/code/home" &&
find . -maxdepth 2 |
	grep -v "/CVS$" | grep -v "/CVS/" |
	sed "s+^./++" | grep -v "^\.$" |

	grep "$GREPBY" |
	
	while read X
	do
		NICESOURCE="~/$X"
		SOURCE="$JPATH/code/home/$X"
		DEST="$HOME/$X"
		if [ ! -d "$DEST" ] && [ ! -f "$DEST" ]
		then
			echo "linking: ~/$X <- $SOURCE"
			ln -sf "$SOURCE" "$DEST"
		else
			if [ ! `realpath "$DEST"` = `realpath "$SOURCE"` ]
			then
				echo "problem: $NICESOURCE is in the way of $SOURCE"
				if [ "$SHOWDIFFS" ] && [ -f "$DEST" ]
				then
					gvimdiff "$DEST" "$SOURCE"
				fi
			else
				: # echo "ok: $NICESOURCE"
			fi
		fi
	done
