# b: move back in directory history
# Does processing, and then echos the correct cd command

# Would like it to roll up one line ;)
# echo -en "\006"

SEARCHDIR="$1"

if [ "$SEARCHDIR" = "" ]; then
  LAST=`tail -1 $HOME/.dirhistory`
else
  # LAST=`grep "$SEARCHDIR" $HOME/.dirhistory | tail -1`
  # Exact:
  LAST=`grep "$SEARCHDIR$" $HOME/.dirhistory | tail -1`
fi

# echo "\"$@\""
# echo "last=$LAST"

echo "$LAST" > $HOME/.dirhistory2
grep -v "^$LAST$" $HOME/.dirhistory >> $HOME/.dirhistory2
mv -f $HOME/.dirhistory2 $HOME/.dirhistory

# export PWD='$LAST';
# alias cd='cd'
"cd" "$LAST"

xttitle "($USER@$HOST:$PWD) %% "
