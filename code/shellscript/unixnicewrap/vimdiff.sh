EXTRAARGS="+0" ## (aiming for null)
HIGHLIGHTSRC="$HOME/.vim/joey/joeyhighlight.vim"
if test -f "$HIGHLIGHTSRC"
then EXTRAARGS="+:so $HIGHLIGHTSRC"
fi

SOFAR=0
for X
do SOFAR=`expr "$SOFAR" + \`longestline "$X"\``
done

if test "$COLUMNS" = ""; then
	COLUMNS="80"
	echo "Please export COLUMNS"
fi
# echo "columns=$COLUMNS, needed=$SOFAR"

if test "$COLUMNS" -lt "$SOFAR" && xisrunning; then
	# echo "Terminal not wide enough, forking."
	echo "Terminal width $COLUMNS < $SOFAR needed, forking."
	if test "$SOFAR" -gt "160"; then
		SOFAR="160"
	fi
	xterm -geometry "$SOFAR"x`expr "$SOFAR" / 2` -e `jwhich vimdiff` "$EXTRAARGS" "$@"
else
	`jwhich vimdiff` "$EXTRAARGS" "$@"
fi
