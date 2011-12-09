# b: move back in directory history

[ "$SUPPRESS_PREEXEC" = undo ] && SUPPRESS_PREEXEC=

SEARCHDIR="$1"

LAST=`grep "$SEARCHDIR" "$HOME/.dirhistory" | 'tail' -n 1`

## Put the directory we're moving from at the top of the history (looping)
echo "$PWD" > $HOME/.dirhistory2
grep -v "^$LAST$" $HOME/.dirhistory >> $HOME/.dirhistory2
mv -f $HOME/.dirhistory2 $HOME/.dirhistory

# export PWD='$LAST'
if [ "$LAST" ]
then 'cd' "$LAST"
else echo "X `cursered;cursebold`$SEARCHDIR`cursenorm`" # beep
fi

# dirhistory "$@"

xttitle "$SHOWUSER$SHOWHOST$PWD %% "
