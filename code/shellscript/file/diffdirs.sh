if [ "$1" = -showdiffswith ]
then
	SHOWDIFFSWITH="$2"
	shift; shift
fi

DIRA="$1"
DIRB="$2"

findfiles () {
	cd "$1"
	find . -type f
}

(
	( findfiles "$DIRA" )
	( findfiles "$DIRB" )
) |

removeduplicatelines |

while read FILE
do

	if [ ! -f "$DIRA/$FILE" ]
	then
		echo "Only in $DIRB: $FILE"
	elif [ ! -f "$DIRB/$FILE" ]
	then
		echo "Only in $DIRA: $FILE"
	else
		if cmp "$DIRA/$FILE" "$DIRB/$FILE" > /dev/null
		# if test "`qkcksum "$DIRA/$FILE" | takecols 1 2`" = "`qkcksum "$DIRB/$FILE" | takecols 1 2`" ## only faster for bigger files!
		then noop # echo "Identical: $FILE"
		# else echo "Differ: $FILE"
		else
			echo "Differ: \"$DIRA/$FILE\" \"$DIRB/$FILE\""
			if [ "$SHOWDIFFSWITH" ]
			then
				echo "Here are the differences:"
				$SHOWDIFFSWITH "$DIRA/$FILE" "$DIRB/$FILE"
				echo
			fi
		fi
	fi

done
