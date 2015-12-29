# f: move forward in directory history

[ "$SUPPRESS_PREEXEC" = undo ] && SUPPRESS_PREEXEC=

SEARCHDIR="$1"

NEXT=`grep -e "$SEARCHDIR" $HOME/.dirhistory | head -n 1`

# Put top directory at bottom of list
grep -vxF "$NEXT" $HOME/.dirhistory > $HOME/.dirhistory2
echo "$PWD" >> $HOME/.dirhistory2
mv -f $HOME/.dirhistory2 $HOME/.dirhistory

# export PWD='$NEXT'
if [ -n "$NEXT" ]
then 'cd' "$NEXT"
else echo "X `cursered;cursebold`$SEARCHDIR`cursenorm`" # beep
fi

# dirhistory "$@"

[ -n "$UPDATE_XTTITLE_ON_DIR_CHANGE" ] && xttitle "$SHOWUSER$SHOWHOST$PWD %% "

true
