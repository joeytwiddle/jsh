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
	echo "  symlinks Joey's rc scripts $HOME/rc_files/* into your own homedir $HOME"
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
	echo "  If you want to link files from a different location, set LINK_FROM."
	echo "  If you want to link files *to* a different location, set LINK_TO."
	echo
	echo '    LINK_FROM="$HOME/rc_files.solaris" LINK_TO=/home/joey/solaris linkhome'
	echo
	exit 1
fi

GREPBY="$1"
if [ "$GREPBY" ]
then DEPTH=7
else DEPTH=2
fi

#[ -z "$LINK_FROM" ] && LINK_FROM="$JPATH/code/home"
[ -z "$LINK_FROM" ] && LINK_FROM="$HOME/rc_files"
[ -z "$LINK_TO" ] && LINK_TO="$HOME"

LINK_FROM="`realpath "$LINK_FROM"`"

[ -d "$LINK_FROM" ] &&
cd "$LINK_FROM" &&
find . -maxdepth $DEPTH |
	grep -v "/CVS$" | grep -v "/CVS/" |
	sed "s+^./++" | grep -v "^\.$" |

	grep "$GREPBY" |

	# Doesn't work: catwithprogress |
	
	while read X
	do
		# SOURCE="$LINK_FROM/$X"
		SOURCE="$LINK_FROM/$X"
		DEST="$LINK_TO/$X"
		NICEDEST="$DEST"   # If possible, turn '$HOME/' into '~/' e.g. using a "path simplifier"
		if [ ! -d "$DEST" ] && [ ! -f "$DEST" ]
		then
			DESTDIR=`dirname "$DEST"`
			if [ ! -d "$DESTDIR" ]
			then
				echo "`cursered;cursebold`cannot link`cursenorm` no folder `cursegreen`$DESTDIR`cursenorm` for $SOURCE"
			else
				echo "`curseyellow`linking`cursenorm` ~/$X `cursegreen`->`cursenorm` $SOURCE"
				ln -sf "$SOURCE" "$DEST"
			fi
		else
			if [ ! "`realpath "$DEST"`" = "`realpath "$SOURCE"`" ]
			then
				echo "`cursered;cursebold`problem`cursenorm` $NICEDEST `cursered;cursebold`is in the way of`cursenorm` $SOURCE"
				if [ -f "$DEST" ] && [ -f "$SOURCE" ] && cmp "$DEST" "$SOURCE"
				then echo "         but they are identical, so why not: del \"$NICEDEST\""
				fi
				if [ -n "$SHOWDIFFS" ] && [ -f "$DEST" ]
				then
					gvimdiff "$DEST" "$SOURCE"
				fi
			else
				[ -z "$QUIET" ] && echo "`cursegreen`ok`cursenorm` $NICEDEST"
			fi
		fi
	done

