#!/bin/sh
# jsh-depends: startswith
## Returns you a long list of URLs from all your browsers,
## in the format: <url> <description>
## Currently implemented: Konqueror, Mozilla, Mozilla Firebird.
## I didn't bother trying to retain folder name/path, but Galeon made me!

isurl () {
		startswith "$URL" "http://" ||
		startswith "$URL" "https://" ||
		startswith "$URL" "ftp://" ||
		startswith "$URL" "file://" ||
		startswith "$URL" "javascript://"
}



if [ "$1" = -inhtml ]
then

	shift

	echo "<HTML><HEAD><TITLE>All bookmarks for $USER on $HOSTNAME</TITLE></HEAD><BODY>"
	bookmarks "$@" |
	## BUG TODO: problems with bookmarklets which contain space characters
	## CONSIDER: could seek "[" provided all browsers types output it (they do atm) but then we'd need to strip " " from end of \1
	sed 's+^\([^ ]*\) \(.*\)+<A href="\1">\2</A><BR>+'
	echo "</BODY></HTML>"

	exit

fi



### Konqueror:

INFOLDER="(none)"

KDEBOOKMARKS="$HOME/.kde/share/apps/konqueror/bookmarks.xml"
if [ -f "$KDEBOOKMARKS" ]
then

	jshinfo "Reading $KDEBOOKMARKS ..."
	cat "$KDEBOOKMARKS" |
	grep  "^[ 	]*<\(folder\|bookmark\|title\)[ >]" |
	sed 's+^[ 	]*<folder.*+FOLDER+' |
	sed 's+^[ 	]*<bookmark.*href="\([^"]*\)".*+BOOKMARK \1+' |
	sed 's+^[ 	]*<title>++;s+</title>++' |
	# pipeboth |

	while read TYPE URL
	do

		if [ "$TYPE" = FOLDER ]
		then
			read INFOLDER

		elif [ "$TYPE" = BOOKMARK ]
		then
			read TITLE
			echo "$URL [Konqueror/$INFOLDER] $TITLE"

		else
			error echo "Unknown: $TYPE"

		fi

	done

fi



### Mozilla and friends:

# MOZBOOKMARKS="$HOME/.mozilla/*/*/bookmarks.html"
# $HOME/.firebird
find $HOME/.mozilla/ $HOME/.phoenix/ $HOME/.firefox/ $HOME/.icedove/ -name bookmarks.html |
while read MOZBOOKMARKS
do
	jshinfo "Reading $MOZBOOKMARKS ..."
	SOURCE="`echo "$MOZBOOKMARKS" | afterfirst "\." | beforefirst "/"`"
	cat "$MOZBOOKMARKS" |
	grep "HREF=" |
	sed 's+.*HREF="\([^"]*\)"[^>]*>\([^<]*\)<.*+\1 ['"$SOURCE"'] \2+'
done



### Galeon:

find $HOME/.galeon -name bookmarks.xbel |
while read GALBOOKMARKS
do
	jshinfo "Reading $GALBOOKMARKS ..."
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
		echo "$URL [Galeon/$FOLDER] $TITLE"
	done
done



### Opera:

## @DISABLED was broken aka stalling
OPERAFILE="$HOME"/.opera/opera6.adr
if [ -f "$OPERAFILE" ]
then

	INFOLDER="(none)"

	jshinfo "Reading $OPERAFILE ..."
	cat "$OPERAFILE" |
	(
	while read LINE
	do

		jshinfo "LINE=$LINE"

		if [ "$LINE" = "#FOLDER" ]
		then
			read IDLINE || exit
			read LINE || exit
			INFOLDER=`echo "$LINE" | after "NAME="`

		elif [ "$LINE" = "#URL" ]
		then
			read IDLINE || exit
			read LINE || exit
			NAME=`echo "$LINE" | after "NAME="`
			read LINE || exit
			URL=`echo "$LINE" | after "URL="`
			echo "$URL [Opera/$INFOLDER] $NAME"

		fi
	
	done
	)

fi



### Chrome:

# TODO: Capture folders

#chrome_bookmarks_file=/home/joey/.config/chromium/Default/Bookmarks
chrome_bookmarks_file=/home/joey/.config/google-chrome/Default/Bookmarks
if [ -f "$chrome_bookmarks_file" ]
then
	jshinfo "Reading $chrome_bookmarks_file ..."
	grep '^\s*"\(name\|url\|type\)"' "$chrome_bookmarks_file" |
	#afterfirst ':' | afterfirst '"' | beforelast '"' |
	# In the file I had, bookmarks had: name, type="url", url
	#                    folders   had: children, name, type="folder"
	sed 's+^\s*"\([^"]*\)":\s*"\([^"]*\)"[ 	,]*$+\1 \2+' |
	while read key value
	do
		# Collect properties
		if [ "$key" = "name" ]
		then name="$value"
		elif [ "$key" = "url" ]
		then url="$value"
		elif [ "$key" = "type" ]
		then type="$value"
		fi
		# Print (once all data is collected)
		if [ "$key" = "url" ] && [ "$type" = "url" ]
		then printf "%s\n" "$url [chrome] $name"
		fi
	done
fi

