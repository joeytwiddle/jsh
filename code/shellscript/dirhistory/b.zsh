# b: move back in directory history
# Does processing, and then echos the correct cd command

# set > /tmp/b.zsh_set.out

## Ah bash is having problems again.
## the sourced script is not passed the arguments properly!

# Would like it to roll up one line ;)
# echo -en "\006"

SEARCHDIR="$1"

# LIST=`grep "$SEARCHDIR" $HOME/.dirhistory | tail -5`
# echo "$LIST"
# LAST=`echo "$LIST" | tail -1`

## Bash when sourced does not pass args properly (well that was when I incorrectly had "set show-all-if-ambiguous On" in startj
# if test ! "$ZSH_NAME"
# then
	# echo "Bash passed:"
	# echo "\$\_ = >$_<"
	# echo "\$\0 = >$0<"
	# echo "\$\# = >$#<"
	# echo "\$\* = >$*<"
	# echo "\$\FUNCNAME = >$FUNCNAME<"
	# echo "\$\LASTCMD = >$LASTCMD<"
	# SEARCHDIR=""
# fi
# echo "SEARCH=>$SEARCHDIR<"

# grep "$SEARCHDIR" "$HOME/.dirhistory"
LAST=`grep "$SEARCHDIR" "$HOME/.dirhistory" | tail -1`

# echo "\"$@\""
# echo "last=$LAST"

echo "$LAST" > $HOME/.dirhistory2
grep -v "^$LAST$" $HOME/.dirhistory >> $HOME/.dirhistory2
mv -f $HOME/.dirhistory2 $HOME/.dirhistory

# export PWD='$LAST';
# alias cd='cd'
"cd" "$LAST"

# dirhistory "$@"

xttitle "$SHOWUSER$SHOWHOST$PWD %% "
