## Returns you a long list of URLs from all your browsers,
## in the format: <url> <description>
## Currently implemented: Konqueror, Mozilla, Mozilla Firebird.
## I didn't bother trying to retain folder name/path, but Galeon made me!

function isurl () {
		startswith "$URL" "http://" ||
		startswith "$URL" "https://" ||
		startswith "$URL" "ftp://" ||
		startswith "$URL" "file://"
}
	

KDEBOOKMARKS="$HOME/.kde/share/apps/konqueror/bookmarks.xml"
if [ -f "$KDEBOOKMARKS" ]
then
	cat "$KDEBOOKMARKS" |
	grep "<\(bookmark \|title\)" |
	sed 's+.*href="++;s+" >++' |
	sed 's+.*<title>++;s+</title>++' |
	while read URL
	do
		read TITLE
		echo "$URL [Konqueror] $TITLE"
	done
fi

# MOZBOOKMARKS="$HOME/.mozilla/*/*/bookmarks.html"
find $HOME/.mozilla $HOME/.phoenix -name bookmarks.html |
while read MOZBOOKMARKS
do
	if echo "$MOZBOOKMARKS" | grep "\.phoenix" >/dev/null
	then SOURCE=Firebird
	else SOURCE=Mozilla
	fi
	cat "$MOZBOOKMARKS" |
	grep "HREF=" |
	sed 's+.*HREF="\([^"]*\)"[^>]*>\([^<]*\)<.*+\1 ['"$SOURCE"'] \2+'
done

find $HOME/.galeon -name bookmarks.xbel |
while read GALBOOKMARKS
do
	cat "$GALBOOKMARKS" |
	grep "\(<title>\|<bookmark \)" |
	sed 's+.*<title>\(.*\)</title>+\1+' |
	sed 's+.*<bookmark href="\([^"]*\)">+\1+' |
	while read URL
	do
		# while ! echo "$URL" | grep "^\(http\|ftp\|file\|https\)://" > /dev/null
		# while [ "${URL#http://}" = "$URL" ] &&
		      # [ "${URL#https://}" = "$URL" ] &&
		      # [ "${URL#ftp://}" = "$URL" ] &&
		      # [ "${URL#file://}" = "$URL" ]
		# while ! startswith "$URL" "http://" &&
		      # ! startswith "$URL" "https://" &&
		      # ! startswith "$URL" "ftp://" &&
		      # ! startswith "$URL" "file://"
		while ! isurl "$URL"
		do
			# echo "Skipping folder $URL" >&2
			FOLDER="$URL" ## Only records last branch, not whole path.  (That info now lost by ungrepping "</folder".)
			read URL || break
		done
		read TITLE
		echo "$URL [Galeon]/$FOLDER $TITLE"
	done
done

## TODO: Opera!
