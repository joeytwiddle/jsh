### Configuration and command-line argument parsing

URLFILE="$HOME/.jsh-watchwebpages/urlstowatch.list"
CACHEDIR="$HOME/.jsh-watchwebpages/cache/"

if ! tty > /dev/null ## no tty => we might be running in cron!
then NOTIFY_BY_EMAIL=true
else NOTIFY_BY_EMAIL=
fi

if [ "$1" = -email ]
then NOTIFY_BY_EMAIL=true; shift
fi

if [ "$MAILTO" ]
then REPORTTO="$MAILTO"
# elif [ "$REPLYTO" ]
# then REPORTTO="$REPLYTO"
else REPORTTO="$USER"
fi

if [ ! -d "$CACHEDIR" ]
then mkdir -p "$CACHEDIR"
fi

if [ "$1" = --help ] || ( [ ! -f "$URLFILE" ] && [ ! "$1" ] )
then
	echo
	echo "watchwebpages [ -email ] [ <url>s ]"
	echo
	echo "  Gets each web page in the list of urls, and compares it to the previous copy."
	echo "  If a web page has changed, then an HTML diff is created for the user."
	echo
	echo "  Without any arguments, the list of URLs is read from $URLFILE ."
	echo
	exit 1
fi

### Get the list of URLs (from command-line arguments or from a file) into suitable form

if [ "$1" ]
then
	for URL
	do echo "$URL"
	done
else
	cat "$URLFILE"
fi |

while read URL
do

	### Obtain a webpage, check if it has changed, and prepare a diff if it has

	echo "##############################################################################"
	echo

	HASH=`echo "$URL" | md5sum | tr -d ' -'`

	OLDFILE="$CACHEDIR/$HASH.html"
	NEWFILE="$CACHEDIR/$HASH-new.html"
	DESTINATION="$CACHEDIR/$HASH-diffed.html"

	if [ -f "$NEWFILE" ]
	then mv "$NEWFILE" "$OLDFILE"
	fi

	wget -nv "$URL" -O "$NEWFILE"
	echo

	if [ ! -f "$OLDFILE" ]
	then

		echo "First time page was loaded, not comparing."

	else

		if cmp "$OLDFILE" "$NEWFILE" > /dev/null
		then
			
			echo "No changes found to $URL"

		else

			echo "Changes found to $URL"
			diffhtml "$OLDFILE" "$NEWFILE" > "$DESTINATION"

			if [ "$NOTIFY_BY_EMAIL" ]
			then

				echo "Notifying $REPORTTO by email."
				(
					echo "Changes found to $URL"
					# echo
					# filesize "$OLDFILE" "$NEWFILE"
					# 'ls' -l "$OLDFILE" "$NEWFILE" "$DESTINATION"
					# echo
					[ "$HOST" ] || HOST=`hostname`
					[ "$USER" ] || USER=$UID
					echo "  [ Sent by \"watchwebpages\" running as $USER on $HOST at `date` ]"
 				) |

				mutt -a "$DESTINATION" -s "[wwc] Changes found to $URL" "$REPORTTO"

				# del "$DESTINATION"

			else

				echo "You can view the differences in file://$DESTINATION"

			fi

		fi

	fi

	echo

done
