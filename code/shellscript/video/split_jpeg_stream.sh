if [ "$1" = "" ] || [ "$1" = --help ]
then
more << !

  split_jpeg_stream <saved_http_stream>

    will split a jpeg stream into its component jpeg image frames, saving them
    as frame-<nnnn>.jpg in the current directory.

    These are the sorts of streams that a webserver (eg. a webcam) can send
    to graphical webbrowsers to display a sequence of images.

    But I found if I saved a copy of the stream (using wget), I could not play
    it back, hence this script.

!
exit 1
fi

STREAMFILE="$1"

FRAMENUM=0

# cat "$1" | tee /tmp/tmpfile.tmp |
cat "$1" |
mimencode -q |
# | pipeboth 2> /tmp/tmpfile.tmp |

while read CONTENT TYPE
do

	[ "$CONTENT" = "Content-type:" ] && [ "$TYPE" = image/jpeg ] || continue

	PADDEDFRAMENUM=`printf "%05i\n" "$FRAMENUM"` ## pads the number
	FRAMEFILE="frame-$PADDEDFRAMENUM.jpg"
	## (Oddly, if we pass padded numbers back round the loop, printf breaks on 0008!)

	read EMPTYLINE

	## Even with mimencode (and post-filtering), I cannot get echo or printf to faithfully reproduce what was read.
	## I can reproduce '\'s by sedding them into '\\'s,
	## but there are still problems reproducing leading/trailing ' 's or '\t's,
	## and other "special" chars.
	# while read LINE
	# do
		# [ "$LINE" = "--ThisRandomString" ] && break
		# printf "%s\n" "$LINE"
		# # set | grep -A2 "^LINE=" >&2
		# # echovar LINE
		# # tail -n 1 /tmp/tmpfile.tmp
	# done |

	## At time of writing, toline defaults to nullifying the rest of the stream, but we want it, so:
	# env TOLINE_LEAVE_REST=true \
	# toline "^--ThisRandomString$" |
	## An inline copy of toline:
	# AWKOPTS="-W interactive"
	PAT="^--ThisRandomString$"
	awk $AWKOPTS ' /'"$PAT"'/ { exit } { print $0'\n' } ' |

	mimencode -q -u > "$FRAMEFILE"

	echo "Written $FRAMEFILE"
	[ "$DEBUG" ] && ls -l "$FRAMEFILE"
	[ "$DEBUG" ] && file "$FRAMEFILE"

	FRAMENUM=`expr "$FRAMENUM" + 1`

done
