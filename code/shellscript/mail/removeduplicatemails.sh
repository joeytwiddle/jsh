CACHEFILE="$HOME/.msgid_cache.formail"

if test "$1" = "-f"; then
	shift
elif test "$1" = "-d"; then
	shift
	rm "$CACHEFILE"
else
	if test -f "$CACHEFILE"; then
		echo "Warning, message ID cache file $CACHEFILE already contains a list of previously seen messages."
		echo "Use -d to delete the cache, or -f to force removal of these messages."
		exit 1
	fi
fi

for X
do
	mv "$X" "$X.old"
	formail -D 10000000 "$CACHEFILE" -s < "$X.old" > "$X"
	# ls -l "$X.old"
	# ls -l "$X"
	OLDSZ=`ls -l "$X.old" | takecols 5`
	SZ=`ls -l "$X" | takecols 5`
	COMPRESSION=` expr "(" "$OLDSZ" - "$SZ" ")" "*" "100" "/" "$OLDSZ" `
	echo "Shrunk by $COMPRESSION%: $X"
done
