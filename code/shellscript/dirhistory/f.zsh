# see b

# Put top directory at bottom of list
LAST=`head -n 1 $HOME/.dirhistory`
grep -v "^$LAST$" $HOME/.dirhistory > $HOME/.dirhistory2
echo "$LAST" >> $HOME/.dirhistory2
mv -f $HOME/.dirhistory2 $HOME/.dirhistory

ARGS="$@";

if [ "$ARGS" = "" ]; then
  NEXT=`head -n 1 $HOME/.dirhistory`
else
  NEXT=`grep "$ARGS" $HOME/.dirhistory | head -n 1`
fi

# echo "cd $NEXT"
export PWD='$NEXT';
# alias cd='cd'
"cd" "$NEXT"

xttitle "$USER@$HOST:$PWD"
