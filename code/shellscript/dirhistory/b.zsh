# b: move back in directory history

# See also: pushd <dir>, popd
# See also: cd - (one step only)

[ "$SUPPRESS_PREEXEC" = undo ] && SUPPRESS_PREEXEC=

SEARCHDIR="$1"

LAST=`grep -e "$SEARCHDIR" "$HOME/.dirhistory" | 'tail' -n 1`

if [ -n "$LAST" ]
then
    ## Put the directory we're moving from at the top of the history (looping)
    echo "$PWD" > $HOME/.dirhistory2
    grep -vxF "$LAST" $HOME/.dirhistory >> $HOME/.dirhistory2
    'mv' -f $HOME/.dirhistory2 $HOME/.dirhistory

    # export PWD='$LAST'
    'cd' "$LAST"
else
    echo "X `cursered;cursebold`$SEARCHDIR`cursenorm`" # beep
fi

# dirhistory "$@"

[ -n "$UPDATE_XTTITLE_ON_DIR_CHANGE" ] && xttitle "$SHOWUSER$SHOWHOST$PWD %% "

true
