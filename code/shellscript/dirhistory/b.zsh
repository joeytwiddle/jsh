# b: move back in directory history
# Does processing, and then echos the correct cd command

ARGS="$@"

if [ "$ARGS" = "" ]; then
  LAST=`tail -1 $HOME/.dirhistory`
else
  LAST=`grep "$@" $HOME/.dirhistory | tail -1`
fi

# echo "\"$@\""
# echo "last=$LAST"

echo "$LAST" > $HOME/.dirhistory2
grep -v "^$LAST$" $HOME/.dirhistory >> $HOME/.dirhistory2
mv -f $HOME/.dirhistory2 $HOME/.dirhistory

# export PWD='$LAST';
# alias cd='cd'
"cd" "$LAST"
