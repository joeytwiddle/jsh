# jsh-depends: beforelast
if test "$1" = ""; then
	ROOT="/"
else
	ROOT="$1"
fi

cat "$ROOT/etc/urpmi/urpmi.cfg" |
grep "{" | beforelast "{" |
grep -v "removable://" |
sed "s/ 	$//g" |
while read SRC; do
	echo "# Source $SRC:"
	LISTFILE="$ROOT/var/lib/urpmi/list.$SRC"
	if test -f "$LISTFILE"; then
		URL=`head -1 "$LISTFILE" |
			beforelast "/"`
		# echo "# has URL $URL"
		echo "urpmi.addmedia "$SRC" \"$URL\" with ../base/hdlist.cz"
	else
		echo "# extract: list file for source \"$SRC\" does not exist: \"$LISTFILE\""
	fi
	echo
done
