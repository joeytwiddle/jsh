# b: move back in directory history

SEARCHDIR="$1"

LAST=`grep "$SEARCHDIR" "$HOME/.dirhistory" | tail -1`

## Put the directory we're moving to at the top of the history (looping)
echo "$LAST" > $HOME/.dirhistory2
grep -v "^$LAST$" $HOME/.dirhistory >> $HOME/.dirhistory2
mv -f $HOME/.dirhistory2 $HOME/.dirhistory

# export PWD='$LAST'
if [ "$LAST" ]
then 'cd' "$LAST"
else echo "X `cursered;cursebold`$SEARCHDIR`cursenorm`" # beep
fi

# dirhistory "$@"

xttitle "$SHOWUSER$SHOWHOST$PWD %% "
