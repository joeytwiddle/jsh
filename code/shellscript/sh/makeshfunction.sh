# jsh-depends: endswith filename startswith error
# makeshfunction `find ~/j/code/shellscript -type f | grep -v /CVS/ | grep -v "\.hs" | grep -v "\.c" | grep -v "\.swp" | grep -v "\.txt$"` > allj.sh

## Notes: It is good that we include the main script itself as a function, in case it tries to make calls to itself.

# Does not appear to speed up processing.  :-(

# export CHECKING=true

if [ ! "$1" ]
then
	echo "makeshfunction <shellscript>"
	exit 1
fi

for FILE in "$@"
do

	FNAME=`
		filename "$FILE" | sed "s/\(.*\)\..*/\1/"
	`

	FIRSTLINE=`head -n 1 "$FILE"`

	SKIP=
	if startswith "$FIRSTLINE" "#!"
	then
		if ! endswith "$FIRSTLINE" "sh"
		then
			error "Cannot import $FNAME function because: $FIRSTLINE"
			SKIP=true
		fi
	fi

	if [ ! $SKIP ]
	then
		# echo "function $FNAME () {"
		# echo "$FNAME () {"
		echo "$FNAME () {" #   # $FILE"
		cat "$FILE" |
		# Not recommended as default, because it can cause problems.
		## Eg. on lines with odd # '"'s: ^[^"]*"[^"]*$ or ^\([^"]*"[^"]*"\)*[^"]*"[^"]*$$
		##                      or '''s
		##                      and what else?
		if [ "$EXPERIMENTAL_INDENT" ]
		then sed 's+^+  +'
		else cat
		fi
		# Needed for files with no trailing \n (TODO: would be nice to check if needed :)
		echo
		echo "}"
	fi

	if [ "$CHECKING" ]
	then
		# cat "$FILE" | grep " \. [a-zA-Z]"
		## TODO: I'm not sure this is even working:
		cat "$FILE" | grep "[^ 	]exit " &&
		echo "\\\\ calls to exit may cause problems!"
	fi >&2

done
