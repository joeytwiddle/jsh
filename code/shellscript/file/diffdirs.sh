DIRA="$1"
DIRB="$2"

findfiles () {
	cd "$1"; find . -type f
}

(
	( findfiles "$DIRA" )
	( findfiles "$DIRB" )
) |

removeduplicatelines |

while read FILE
do

	if test ! -f "$DIRA/$FILE"
	then echo "Only in $DIRB: $FILE"
	elif test ! -f "$DIRB/$FILE"
	then echo "Only in $DIRA: $FILE"
	else
		if cmp "$DIRA/$FILE" "$DIRB/$FILE" > /dev/null
		# if test "`qkcksum "$DIRA/$FILE" | takecols 1 2`" = "`qkcksum "$DIRB/$FILE" | takecols 1 2`" ## only faster for bigger files!
		then noop # echo "Identical: $FILE"
		else echo "Differ: $FILE"
		fi
	fi

done
