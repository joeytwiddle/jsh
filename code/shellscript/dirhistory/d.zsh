# d: change directory and record for b and f shell tools

# Sometimes NEWDIR="$@" breaks under ssh!

NEWDIR="$@"

echo "$PWD" >> $HOME/.dirhistory

# echo "Doing cd $NEWDIR"
# I think "cd" prevents aliasing
if [ "$NEWDIR" = "" ]; then
  "cd" $HOME/..
  # "cd"
elif test -d "$NEWDIR"; then
  'cd' "$NEWDIR"
else
	LIST=`'ls' -d "$NEWDIR"*`
	NEWLIST=`echo "$LIST" | 
		while read X; do
			if test -d "$X"; then
				echo "$X"
			fi
		 done
	`
	if test `echo "$NEWLIST" | countlines` = "1"; then
		echo "> $NEWLIST"
		'cd' "$NEWLIST"
  else
		echo -n "? "
		echo "$NEWLIST" | tr "\n" " "
		echo
		# echo -n "$NEWLIST" | tr "\n" " "
		# echo " ?"
	fi
fi

# pwd >> $HOME/.dirhistory
