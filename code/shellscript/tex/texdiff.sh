DATE="$1"

if test "$DATE" = ""; then
	echo "texdiff <date>"
	exit 1
fi

ORIG="$PWD"
OLDTEX=`jgettmpdir texold`
NEWTEX=`jgettmpdir texnew`
FINALDEST="$ORIG-diffed"

# Get two new copies: one to diff against, one to show changes.
cp -a . "$OLDTEX"
cp -a . "$NEWTEX"

# Get older copy to diff against
cd "$OLDTEX"
del *.tex

cursecyan
echo
echo "Getting older copy"
echo
curseyellow

cvs update -D "$DATE" | grep -v "^\?"

cursecyan
echo
echo "Diffing"
echo
curseyellow

# Do the diff
cd "$NEWTEX"
for X in *.tex; do
	jfc silent diff -ds " \\color{Red} " -dsf " \\color{Black} " "$OLDTEX/$X" "$X"
done

# Move working copy to final destination, and partial cleanup
cd
# del "$FINALDEST"
rm -rf "$FINALDEST"
mv $NEWTEX "$FINALDEST"
jdeltmp $OLDTEX

cursecyan
echo
echo "Retexing"
echo
curseyellow

# Move diffs in, and ...
cd "$FINALDEST"
for X in `beforeext diff`; do
	mv "$X.diff" "$X"
done
# ... reformat document!
./dotex
for X in `beforeext dvi`; do
	cursecyan
	echo
	echo "To postscript..."
	echo
	curseyellow
	dvips -f "$X.dvi" > "$X.ps"
	# Show document
	gv "$X.ps"
done
# xdvi *.dvi

# Final cleanup
# cd
# del "$FINALDEST"
