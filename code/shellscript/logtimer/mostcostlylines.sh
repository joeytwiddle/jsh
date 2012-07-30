export NOPROGRESS=true

## default assumption is that debug line gets printed before the lengthy operation
## if your debug line is printed after the lengthy operation, use --showtoline
if [ "$1" = -showtoline ] ## default: show the "from line"
then SHOWTOLINE=true; shift
fi

"$@" 2>&1 | dateeachline -fine |

sed 's+^\[\([0-9]*\)\.\([0-9]*\)\]+\1\2+' |

while read TIME LINE
do

	if [ "$LASTTIME" ]
	then

		TIMEDIFF=$(($TIME-$LASTTIME))

		# echo "$TIMEDIFF	$LASTLINE"
		if [ "$SHOWTOLINE" ]
		then echo "$TIMEDIFF	$LINE"
		else echo "$TIMEDIFF	$LASTLINE"
		fi
	
	fi

	LASTTIME="$TIME"
	LASTLINE="$LINE"

done |

## For testing:
head -200 |                # numbereachline |
pipeboth --line-buffered | # dropcols 1 |

sort -n -k 1
