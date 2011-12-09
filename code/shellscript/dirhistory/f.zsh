# f: move forward in directory history

[ "$SUPPRESS_PREEXEC" = undo ] && SUPPRESS_PREEXEC=

SEARCHDIR="$1"

NEXT=`grep "$SEARCHDIR" $HOME/.dirhistory | head -n 1`

# Put top directory at bottom of list
grep -v "^$NEXT$" $HOME/.dirhistory > $HOME/.dirhistory2
echo "$PWD" >> $HOME/.dirhistory2
mv -f $HOME/.dirhistory2 $HOME/.dirhistory

# export PWD='$NEXT'
if [ "$NEXT" ]
then 'cd' "$NEXT"
else echo "X `cursered;cursebold`$SEARCHDIR`cursenorm`" # beep
fi

# dirhistory "$@"

xttitle "$SHOWUSER$SHOWHOST$PWD %% "
