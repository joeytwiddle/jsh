# f: move forward in directory history

SEARCHDIR="$1"

LAST=`head -n 1 $HOME/.dirhistory`

# Put top directory at bottom of list
grep -v "^$LAST$" $HOME/.dirhistory > $HOME/.dirhistory2
echo "$LAST" >> $HOME/.dirhistory2
mv -f $HOME/.dirhistory2 $HOME/.dirhistory

if [ "$SEARCHDIR" ]
then NEXT=`grep "$SEARCHDIR" $HOME/.dirhistory | head -n 1`
else NEXT=`head -n 1 $HOME/.dirhistory`
fi

# export PWD='$NEXT'
if [ "$NEXT" ]
then 'cd' "$NEXT"
else echo "X `cursered;cursebold`$SEARCHDIR`cursenorm`" # beep
fi

# dirhistory "$@"

xttitle "$SHOWUSER$SHOWHOST$PWD %% "
