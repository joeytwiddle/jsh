## watchwebpages could watch whole website, but it would have to use -mirror or something (really only html wanted)

### Configuration and command-line argument parsing

## TODO: introduce a measure of difference so user can specify for each page a minimal difference before it is reported (to deal with known continual changes to pages which we don't care about, such as differing adverts, or a display of the webserver's time.)

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
	echo "  If no URLs are provided as arguments, the list of URLs is read from $URLFILE ."
	echo "  In the file, each URL may be followed by a <minbytes> and <minlines> specification."
	echo "  Changes will not be reported if the difference falls below both thresholds."
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

while read URL MINBYTES MINLINES
do

	## I guess MINBYTES and MINLINES could default to 0 if undefined.

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

		# echo "Possible thresholds to avoid reporting minor changes:"

		OLDSIZE=`filesize "$OLDFILE"`
		NEWSIZE=`filesize "$NEWFILE"`
		SIZEDIFF=`expr "$NEWSIZE" - "$OLDSIZE"`
		echo "Size change was: $SIZEDIFF   [$MINBYTES tolerated]   (from $OLDSIZE to $NEWSIZE)"
		[ "$SIZEDIFF" -lt 0 ] && SIZEDIFF=`expr 0 - "$SIZEDIFF"`

		DIFFLINES=`diff "$OLDFILE" "$NEWFILE" | countlines`
		echo "Lines in diff:   $DIFFLINES   [$MINLINES tolerated]"

		echo

		if cmp "$OLDFILE" "$NEWFILE" > /dev/null
		then

			echo "No changes found to $URL"

		else

			## I could not put this logic into a two-clause expression, although I was tired when I tried:
			# if ( [ "$MINBYTES" ] && [ "$SIZEDIFF" -lt "$MINBYTES" ] ) ||
			   # ( [ "$MINLINES" ] && [ "$DIFFLINES" -lt "$MINLINES" ] )

			OVERSIZE=
			if [ "$MINBYTES" ] && [ "$SIZEDIFF" -gt "$MINBYTES" ]
			then OVERSIZE=true; echo "Size $SIZEDIFF exceeds threshold $MINBYTES"
			fi
			if [ "$MINLINES" ] && [ "$DIFFLINES" -gt "$MINLINES" ]
			then OVERSIZE=true; echo "Lines in diff $DIFFLINES exceeds threshold $MINLINES"
			fi
			if [ ! "$MINBYTES" ] && [ ! "$MINLINES" ]
			then OVERSIZE=true
			fi

			if [ ! "$OVERSIZE" ]
			then

				echo "Changes were minor, so no diff is being made."
				cp -f "$OLDFILE" "$NEWFILE"
				## Hence changes are compared to last report, as opposed to last check.
				## This means a number of small minor changes which add up to exceed the thresholds will eventually be reporeted
				## This is good!

			else

				echo "Changes have been found to $URL"
				echo
				diffhtml "$OLDFILE" "$NEWFILE" > "$DESTINATION"

				if [ "$NOTIFY_BY_EMAIL" ]
				then

					echo "You can view the differences in file://$DESTINATION"

					echo "Notifying $REPORTTO by email."
					(
						echo "Changes found to $URL"
						# echo
						# filesize "$OLDFILE" "$NEWFILE"
						# 'ls' -l "$OLDFILE" "$NEWFILE" "$DESTINATION"
						# echo
						echo "You can view the differences (highlighted) in the attached web page."
						echo

						## TODO: if we /do/ skip reporting because changes are minor,
						##       we should probably hang on to the old file rather than the new one,
						##       so minor in different places will add up.

						echo
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

	fi

	echo

done
