#!/bin/sh
## watchwebpages could watch whole website, but it would have to use -mirror or something (really only html wanted)

## TODO: If we perform two immediately successive queries, and compare the result, then the script can make a quick estimate as to the default # changes chars / words caused by eg. advert banners and other non-static elements of the page.

### Configuration and command-line argument parsing

## TODO: introduce a measure of difference so user can specify for each page a minimal difference before it is reported (to deal with known continual changes to pages which we don't care about, such as differing adverts, or a display of the webserver's time.)

[ "$URLFILE" ] || URLFILE="$HOME/.jsh-watchwebpages/urlstowatch.list"
[ "$WWPCACHEDIR" ] || WWPCACHEDIR="$HOME/.jsh-watchwebpages/cache/"

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

if [ ! -d "$WWPCACHEDIR" ]
then mkdir -p "$WWPCACHEDIR"
fi

if [ "$1" = --help ] || ( [ ! -f "$URLFILE" ] && [ ! "$1" ] )
then
	echo
	echo "watchwebpages [ -email ] [ <url>s... ]"
	echo
	echo "  Gets each web page in the list of urls, and compares it to the previous copy."
	echo "  If the web page has changed, then an HTML diff is created for the user."
	echo
	echo "  With the -email option, each diff report is emailed to $REPORTTO (\$MAILTO),"
	echo "  otherwise the reports go to stdout, giving temporary files for each HTML diff."
	echo
	echo "  If no URLs are provided as arguments, the list of URLs is read from the file:"
	echo
	echo "    $URLFILE (\$URLFILE)"
	echo
	echo "  Each line in the file should meet the following format:"
	echo
	echo "    <url> [ <min_bytes> [ <min_lines> [ <diffhtml_option>s... ] ] ]"
	echo
	echo "  The URL may be followed by integer thresholds <min_bytes> and <min_lines>."
	echo "  If the difference falls below both thresholds, changes will not be reported."
	echo
	echo "  Finally, extra options may be provided to diffhtml, e.g. \"-fine\"."
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

while read URL MINBYTES MINLINES DIFFOPTS
do

	## I guess MINBYTES and MINLINES could default to 0 if undefined.

	### Obtain a webpage, check if it has changed, and prepare a diff if it has

	echo "##############################################################################"
	echo
	echo "Checking: $URL"
	echo

	HASH=`echo "$URL" | md5sum | tr -d ' -'`

	OLDFILE="$WWPCACHEDIR/$HASH.html"
	NEWFILE="$WWPCACHEDIR/$HASH-new.html"
	DESTINATION="$WWPCACHEDIR/$HASH-diffed.html"

	if [ -f "$NEWFILE" ]
	then mv "$NEWFILE" "$OLDFILE"
	fi

	wget -U "jsh_watchwebpages" -nv "$URL" -O "$NEWFILE" 2>/dev/null ## hide stderr to avoid cron error reports
	# echo

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
			NL='
'

			THRESHOLD_REPORT=
			OVERSIZE=
			if [ "$MINBYTES" ] && [ "$SIZEDIFF" -gt "$MINBYTES" ]
			then OVERSIZE=true; THRESHOLD_REPORT="$THRESHOLD_REPORT""Size $SIZEDIFF exceeds threshold $MINBYTES""$NL"
			fi
			if [ "$MINLINES" ] && [ "$DIFFLINES" -gt "$MINLINES" ]
			then OVERSIZE=true; THRESHOLD_REPORT="$THRESHOLD_REPORT""Lines in diff $DIFFLINES exceeds threshold $MINLINES""$NL"
			fi
			if [ ! "$MINBYTES" ] && [ ! "$MINLINES" ]
			then OVERSIZE=true
			fi
			echo "$THRESHOLD_REPORT"

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
				diffhtml $DIFFOPTS "$OLDFILE" "$NEWFILE" > "$DESTINATION"

				if [ "$NOTIFY_BY_EMAIL" ]
				then

					## Only uncomment these if $DESTINATION is not deleted below.
					# echo "You can view the differences in:"
					# echo "  file://$DESTINATION"

					echo "Notifying $REPORTTO by email."
					(
						echo "Changes found to $URL, sizediff $SIZEDIFF ($MINBYTES tolerated), linesdiff $DIFFLINES ($MINLINES tolerated)"
						# echo
						# filesize "$OLDFILE" "$NEWFILE"
						# 'ls' -l "$OLDFILE" "$NEWFILE" "$DESTINATION"
						# echo
						echo "$THRESHOLD_REPORT"
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

					## -F "" to avoid config file didn't work, which avoids user preferences, eg. save outgoing mail to sent-mail mailbox.
					## Nope it doesn't work!!  Ah, but -F /dev/null did :)
					mutt -F /dev/null -a "$DESTINATION" -s "[wwp] Changes found to $URL" "$REPORTTO"
					## Also consider: -e "mutt commands"

					del "$DESTINATION"

				else

					echo "You can view the differences in:"
					echo
					echo "  file://$DESTINATION"

				fi

			fi

		fi

	fi

	echo

done
