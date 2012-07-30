svnstatus () {
	memo svn status
}

memo -c true svn status

findclosest () {
	SINGLE="$1"
	shift
	echo "Closest to $SINGLE :" >&2
	for OTHER
	do
		[ -f "$OTHER" ] || continue
		diff "$SINGLE" "$OTHER" | countlines | tr -d '\n'
		echo "	$OTHER"
	done |
	pipeboth |
	sort -n -k 1 |
	head -1 |
	dropcols 1
}

REMOVEDFILES=`svn status | grep '^\!' | dropcols 1`
ADDEDFILES=`svn status | grep '^\?' | dropcols 1`
MODIFIEDFILES=`svn status | grep '^M' | dropcols 1`

REPORT=""
NL='
'

cursecyan

## Retrieve removed files somewhere temporary
## OK so at the moment we retrieve them locally
printf "%s" "$REMOVEDFILES" | withalldo svn update

# printf "%s" "$ADDEDFILES" |
# while read ADDED
for ADDED in $ADDEDFILES
do

	:
	## diffgraph them to find which is closest
	## Suggest svn move etc.
	# printf "%s" "$REMOVEDFILES" | withalldo findclosest "$ADDED"
	CLOSEST=`findclosest "$ADDED" $REMOVEDFILES`
	if [ "$CLOSEST" ]
	then
		REPORT="$REPORT$NL""## It looks like:"
		REPORT="$REPORT$NL""##   $ADDED"
		REPORT="$REPORT$NL""## came from:"
		REPORT="$REPORT$NL""##   $CLOSEST"
		REPORT="$REPORT$NL""## You could:"
		REPORT="$REPORT$NL""svn update \"$CLOSEST\""
		REPORT="$REPORT$NL""## Next line needed if the files are not identical (not score 0 above):"
		REPORT="$REPORT$NL""mv \"$ADDED\" \"$ADDED\".new"
		REPORT="$REPORT$NL""svn move \"$CLOSEST\" \"$ADDED\"" ## Will this work if dest files is present (although it should be score 0 if it is)
		REPORT="$REPORT$NL""## Next line needed if the files are not identical (not score 0 above):"
		REPORT="$REPORT$NL""svn commit \"$CLOSEST\" \"$ADDED\"" ## to finalise
		REPORT="$REPORT$NL""mv \"$ADDED\".new \"$ADDED\""
		REPORT="$REPORT$NL""svn commit \"$ADDED\""
		REPORT="$REPORT$NL"
		## These lines optional (determine whether reporting is made during or after queries)
		cursenorm
		echo "$REPORT"
		cursecyan
		REPORT=""
	fi

done

if [ "$REMOVEDFILES" ]
then printf "%s" "$REMOVEDFILES" | withalldo del | striptermchars
fi

cursenorm

echo "$REPORT"
