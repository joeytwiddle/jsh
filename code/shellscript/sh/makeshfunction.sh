# makeshfunction `find ~/j/code/shellscript -type f | grep -v /CVS/ | grep -v "\.hs" | grep -v "\.c" | grep -v "\.swp" | grep -v "\.txt$"` > allj.sh

# Does not seem to speed things up :-(

if test "$1" = ""; then
	echo "makeshfunction <shellscript>"
	exit 1
fi

for FILE in "$@"; do

	FNAME=`
		filename "$FILE" | sed "s/\(.*\)\..*/\1/"
	`

	FIRSTLINE=`head -1 "$FILE"`

	SKIP=
	if startswith "$FIRSTLINE" "#!"; then
		if ! endswith "$FIRSTLINE" "sh"; then
			echo "# not implementing $FNAME because: $FIRSTLINE"
			SKIP=true
		fi
	fi

	if test ! $SKIP; then
		# echo "function $FNAME () {"
		# echo "$FNAME () {"
		echo "$FNAME () {   # $FILE"
		cat "$FILE" # | sed "s/^/  /" # not recommended 'cos cld cause prblms.
		echo # Needed for files with no trailing \n
		echo "}"
	fi

	echo

done
