# jsh-ext-depends-ignore: find file
# jsh-ext-depends: sed
# jsh-depends: curseyellow cursenorm dog
## TODO: Doesn't complain if search string is not there and hence replacement is not made!
##       Could grep but not if piping in->out

if [ ! "$1" ] || [ "$1" = --help ]
then
  echo 'replaceline "search string" "replacement line" [ <file> ]'
	echo '  finds the line(s) containing "search string" and replaces it with "replacement line".'
	echo '  If you want to repeat the process, naturally the "replacement line" should contain the "search string".'
	echo '  Note you cannot use ^ or $ in "search string".'
  exit 1
fi

SEARCH="$1"
REPLACE="$2"
shift
shift

if [ "$*" ]
then
	## test for string with grep
	FILE="$1"
	if ! grep "$SEARCH" "$FILE" > /dev/null
	then
		curseyellow >&2
		echo "% Did not find search string in file \"$FILE\"." >&2
		echo "% You should insert the following line in the file then try again:" >&2
		cursenorm >&2
		echo "$SEARCH" | sed 's+^\^++;s+\$$++' >&2
	fi
fi

cat "$@" |
sed "s.*$SEARCH.*$REPLACE" |
dog "$@"
