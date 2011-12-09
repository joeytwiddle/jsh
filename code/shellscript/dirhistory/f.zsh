# f: move forward in directory history

[ "$SUPPRESS_PREEXEC" = undo ] && SUPPRESS_PREEXEC=

SEARCHDIR="$1"

NEXT=`head -n 1 $HOME/.dirhistory`

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
