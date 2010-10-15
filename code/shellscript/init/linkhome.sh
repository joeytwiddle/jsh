#!/bin/sh
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
	echo "  (Due to inefficiency depth 7 is only attempted if <grep_pattern> is provided.)"
	echo
	echo "  TODO: This script runs really slowly if no 'realpath' binary is present."
	echo "        In the meantime (and in general) you are recommended to install one."
	# echo "        maybe we could check inode instead of path?"
	echo
	exit 1
fi

GREPBY="$1"
if [ "$GREPBY" ]
then DEPTH=7
else DEPTH=2
fi

cd "$JPATH/code/home" &&
find . -maxdepth $DEPTH |
	grep -v "/CVS$" | grep -v "/CVS/" |
	sed "s+^./++" | grep -v "^\.$" |

	grep "$GREPBY" |

	# Doesn't work: catwithprogress |
	
	while read X
	do
		# SOURCE="$JPATH/code/home/$X"
		SOURCE="`realpath "$JPATH/code/home/$X"`"
		DEST="$HOME/$X"
		NICEDEST="~/$X"
		if [ ! -d "$DEST" ] && [ ! -f "$DEST" ]
		then
			echo "`cursegreen`linking`cursenorm`: ~/$X `cursegreen`<-`cursenorm` $SOURCE"
			ln -sf "$SOURCE" "$DEST"
		else
			if [ ! `realpath "$DEST"` = `realpath "$SOURCE"` ]
			then
				echo "`cursered;cursebold`problem:`cursenorm` $NICEDEST `cursered;cursebold`is in the way of`cursenorm` $SOURCE"
				if [ -f "$DEST" ] && [ -f "$SOURCE" ] && cmp "$DEST" "$SOURCE"
				then echo "         but they are identical, so why not: del \"$NICEDEST\""
				fi
				if [ "$SHOWDIFFS" ] && [ -f "$DEST" ]
				then
					gvimdiff "$DEST" "$SOURCE"
				fi
			else
				echo "`cursegreen`ok:`cursenorm` $NICEDEST"
			fi
		fi
	done

