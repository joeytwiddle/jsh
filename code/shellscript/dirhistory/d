# d: change directory and record for b and f shell tools

# Sometimes NEWDIR="$@" breaks under ssh!

NEWDIR="$@"

echo "$PWD" >> $HOME/.dirhistory

# echo "Doing cd $NEWDIR"
# I think "cd" prevents aliasing
if [ "$NEWDIR" = "" ]; then
  "cd"
elif test -d "$NEWDIR"; then
  "cd" "$NEWDIR"
else
	'ls' -d "$NEWDIR"* |
		 while read X; do
			 if test -d "$X"; then
				 echo -n "$X/ "
			 fi
		 done
	 echo "?"
fi

# pwd >> $HOME/.dirhistory
