# b: move back in directory history
# Does processing, and then echos the correct cd command

# Would like it to roll up one line ;)
# echo -en "\006"

SEARCHDIR="$1"

# LIST=`grep "$SEARCHDIR" $HOME/.dirhistory | tail -5`
# echo "$LIST"
# LAST=`echo "$LIST" | tail -1`

LAST=`grep "$SEARCHDIR" "$HOME/.dirhistory" | tail -1`

# echo "\"$@\""
# echo "last=$LAST"

echo "$LAST" > $HOME/.dirhistory2
grep -v "^$LAST$" $HOME/.dirhistory >> $HOME/.dirhistory2
mv -f $HOME/.dirhistory2 $HOME/.dirhistory

# export PWD='$LAST';
# alias cd='cd'
"cd" "$LAST"

dirhistory "$@"

xttitle "$SHOWUSER$SHOWHOST$PWD %% "
