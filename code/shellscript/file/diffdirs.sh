# jsh-depends: cursebold cursegreen cursered curseyellow cursenorm removeduplicatelines
# jsh-ext-depends: diff find
# this-script-does-not-depend-on-jsh: filesize findfiles

## Consider: Instead of "Only in ..." use "Missing" and "Added" when comparing state of second wrt first.

## BUG: -showdiffswith doesn't work for eg. vimdiff, because stdin terminal has already been stolen :(  (xterm -e vimdiff is ok though :)
if [ "$1" = -showdiffswith ]
then
	SHOWDIFFSWITH="$2"
	shift; shift
fi

DIRA="$1"
DIRB="$2"

findfiles () {
	cd "$1"
	# find . -type f
	find . -type f -or -type l
}

(
	( findfiles "$DIRA" )
	( findfiles "$DIRB" )
) |

removeduplicatelines |

while read FILE
do

	if [ ! -f "$DIRA/$FILE" ] && [ -f "$DIRB/$FILE" ] ## Second check is in case both are broken symlinks, although TODO: should really check targets are the same
	then
		echo "`cursegreen`Only in $DIRB/: $FILE`cursenorm`"
	elif [ ! -f "$DIRB/$FILE" ] && [ -f "$DIRA/$FILE" ] ## Second check is in case both are broken symlinks, although TODO: should really check targets are the same
	then
		echo "`cursered;cursebold`Only in $DIRA/: $FILE`cursenorm`"
	else
		# if cmp "$DIRA/$FILE" "$DIRB/$FILE" > /dev/null
		## These are faster alternatives:
		if [ "`filesize "$DIRA/$FILE"`" = "`filesize "$DIRB/$FILE"`" ] ## Note: this detects a symlink to an identical file as different!
		# if test "`qkcksum "$DIRA/$FILE" | takecols 1 2`" = "`qkcksum "$DIRB/$FILE" | takecols 1 2`" ## only faster for bigger files!
		## This was no good, because the filenames are different, and are echoed back!: if [ "`qkcksum \"$DIRA/$FILE\"`" = "`qkcksum \"$DIRB/$FILE\"`" ]
		## This doesn't work on files with spaces: # if test "`qkcksum \`realpath "$DIRA/$FILE"\` | takecols 1 2`" = "`qkcksum \`realpath "$DIRB/$FILE"\` | takecols 1 2`" ## only faster for bigger files!
		# then noop
		then echo "Identical: $FILE"
		# else echo "Differ: $FILE"
		else
			echo "`curseyellow`Differ: diff \"$DIRA/$FILE\" \"$DIRB/$FILE\"`cursenorm`"
			if [ "$SHOWDIFFSWITH" ]
			then
				echo "Here are the differences:"
				$SHOWDIFFSWITH "$DIRA/$FILE" "$DIRB/$FILE"
				echo
			fi
		fi
	fi

done
