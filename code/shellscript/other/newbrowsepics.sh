ARGS="$@"
if [ "$ARGS" = "" ]; then
  IMAGES="*.jpg *.jpeg *.bmp *.xpm *.gif *.pgm *.ppm *.pcx"
else
  IMAGES="$ARGS"
fi

MAXPERPAGE=30

EXTRAS="-geometry 100"
# EXTRAS=""

htmlFile () { # takes num
	echo "ImageIndex$1.html"
}

startHtml () { # takes num
	echo "<html><title>Images Page $1</title><body>"
}

offerPage() { # takes next page number and filename
	echo "<a href=\"$2\">Next Page ($1)</a>"
}

endHtml () { # takes nothing or name of next page
	echo "</body></html>"
}

N=1

HTMLFILE=`htmlFile $N`
startHtml $N > "$HTMLFILE"

n=0

for w in $IMAGES; do

	echo "$n: $w"

	# Note n now loops back!
	# SHOWPIC="browsepics$n.Jpeg"
	# convert $EXTRAS $w "$SHOWPIC"

	SHOWPIC=$w

	echo "<image src=\"$SHOWPIC\"><br>$w<br><br>" >> "$HTMLFILE"

	n=`expr $n + 1`
	if test "$n" = "$MAXPERPAGE"; then
		n=0
		N=`expr $N + 1`
		NEWHTMLFILE=`htmlFile $N`
		offerPage "$N" "$NEWHTMLFILE" >> "$HTMLFILE"
		endHtml >> "$HTMLFILE"
		HTMLFILE="$NEWHTMLFILE"
		echo "Starting page $N"
		startHtml $N > "$HTMLFILE"
	fi

done

endHtml >> "$HTMLFILE"

# browse $HTMLFILE
# netscape $HTMLFILE &

# echo "browsepics*.Jpeg and $HTMLFILE will be deleted in 60 seconds"
# (sleep 60 ; "rm" browsepics*.Jpeg $HTMLFILE) &
