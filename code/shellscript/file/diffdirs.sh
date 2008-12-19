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
	find . -type f -or -type l | sed 's+^\./++' | sort
}

IDCNT=0

function report() {
	if [ "$IDCNT" -gt 0 ]
	then
		[ "$IDCNT" -gt 1 ] && /bin/echo -n " [$IDCNT files]"
		/bin/echo
		IDCNT=0
	fi
	/bin/echo "$@"
}

function identical() {
	if [ "$IDCNT" = 0 ]
	then /bin/echo -n "Identical:" "$@"
	else /bin/echo -n "" "$@"
	fi
	IDCNT=$((IDCNT+1))
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
		report "`cursegreen`Only in $DIRB/: $FILE`cursenorm`"
	elif [ ! -f "$DIRB/$FILE" ] && [ -f "$DIRA/$FILE" ] ## Second check is in case both are broken symlinks, although TODO: should really check targets are the same
	then
		report "`cursered;cursebold`Only in $DIRA/: $FILE`cursenorm`"
	else
		# if cmp "$DIRA/$FILE" "$DIRB/$FILE" > /dev/null
		## These are faster alternatives, but not as thorough:
		if [[ $(filesize "$DIRA/$FILE") = $(filesize "$DIRB/$FILE") ]] ## Note: this detects a symlink to an identical file as different!
		# if test "`qkcksum "$DIRA/$FILE" | takecols 1 2`" = "`qkcksum "$DIRB/$FILE" | takecols 1 2`" ## only faster for bigger files!
		## This was no good, because the filenames are different, and are echoed back!: if [ "`qkcksum \"$DIRA/$FILE\"`" = "`qkcksum \"$DIRB/$FILE\"`" ]
		## This doesn't work on files with spaces: # if test "`qkcksum \`realpath "$DIRA/$FILE"\` | takecols 1 2`" = "`qkcksum \`realpath "$DIRB/$FILE"\` | takecols 1 2`" ## only faster for bigger files!
		# then noop
		then
			# /bin/echo -e -n "\rIdentical: $FILE   "
			identical "$FILE"
		# else report "Differ: $FILE"
		else
			# report "`curseyellow`Differ: diff \"$DIRA/$FILE\" \"$DIRB/$FILE\"`cursenorm`"
			DIFFSUMMARY=`NOEXEC=1 IKNOWIDONTHAVEATTY=1 diffsummary "$DIRA/$FILE" "$DIRB/$FILE"`
			report "`curseyellow`Differ: diff $DIFFSUMMARY`cursenorm`"
			if [ "$SHOWDIFFSWITH" ]
			then
				report "Here are the differences:"
				report $SHOWDIFFSWITH "$DIRA/$FILE" "$DIRB/$FILE"
				report echo
			fi
		fi
	fi

done

## Dammit we lost our value of IDCNT!
# if [ "$IDCNT" -gt 0 ]
# then echo
# fi
echo

