# jsh-ext-depends: mplayer
# jsh-ext-depends-ignore: script last from make file time clip play
# jsh-depends-ignore: before mplayer
# jsh-depends: cursecyan cursegreen curseyellow cursenorm afterfirst beforefirst beforelast rotate extract_marked_clips_from_video

## TODO: allow interactive labelling of marks -> filename, or optionally undo the last unwanted mark.

CLIPMARKERFILE=/tmp/clipmarkers.txt

if [ ! "$1" ] || [ "$1" = --help ]
then
more << !

extract_clips_from_video <video_file> [ <mplayer/mencoder_options> ]

  will play the video file in mplayer, and allow you to mark the positions of
  clips you want to extract.  This can be useful to get small clips out of a
  large video before importing the clips to a video editing package.

  The script watches for whenever you PAUSE the playback (by pressing <SPACE>).

    * The first time you PAUSE marks the beginning of a clip you want to
      extract (an In_Mark).

    * The second PAUSE marks the end of the clip (an Out_Mark), and the two
      timepoints are written to the file: $CLIPMARKERFILE

  If you accidentally mark an unwanted In_Mark, you should mark the
  corresponding Out_Mark and then delete the last line from the file.

  The format of the video file will influence the accuracy of the marked time
  points.  To be safe, make longer clips than you need, with a gap at each end.

!
exit 1
fi

VIDEOFILE="$1"
shift

## Backup the marker file in case you realise u wanted an older one!
[ -f "$CLIPMARKERFILE" ] && which rotate >/dev/null && rotate -nozip "$CLIPMARKERFILE"

echo "# Start	End	(Optional_clip_name)" > "$CLIPMARKERFILE"

echo
echo "OK now hit PAUSE to mark in and out points."
echo
curseyellow

MARKERTYPE=In_Mark
LASTMARKERPOS=not_yet_set

## gmplyer doesn't give the output!
## Oh well it does now on my sys so now it's back in:
MPLAYER=`which gmplayer`
[ "$MPLAYER" ] || MPLAYER=`which mplayer`

$MPLAYER "$@" "$VIDEOFILE" 2>&1 |

# sed 's++'`echo`'+g' |

tr '' '\n' |

## Would make pause recognition more responsive, if it didn't buffer the stream
# grep -A1 "PAUSE" |

while read LINE
do

	# printf "%s\r" "$LINE" >&2

	## Ignore all lines until the user hits pause
	if echo "$LINE" | grep "=====  PAUSE  =====" > /dev/null
	then

		## Read the next line and extract the juicy info from it
		read LINE
		AUDIOPOS=`echo "$LINE" | afterfirst ':' | beforefirst ':' | beforelast ' '`
		VIDEOPOS=`echo "$LINE" | afterfirst ':' | afterfirst ':' | beforefirst ':' | beforelast ' '`

		## I chose here to base markers on video time position; swap AUDIOPOS for VIDEOPOS to use audio time position
		MARKERPOS=$VIDEOPOS
		# MARKERPOS=$VIDEOPOS

		echo "User has set $MARKERTYPE at $MARKERPOS seconds"

		if [ "$MARKERTYPE" = Out_Mark ]
		then
			echo "Adding clip $LASTMARKERPOS -> $MARKERPOS to $CLIPMARKERFILE"
			echo "$LASTMARKERPOS	$MARKERPOS	" >> "$CLIPMARKERFILE"
			echo
			MARKERTYPE=In_Mark
		else
			LASTMARKERPOS=$MARKERPOS
			MARKERTYPE=Out_Mark
		fi

	fi

done

cursenorm

echo
echo "Clip markers have been saved to `cursecyan`$CLIPMARKERFILE`cursenorm`"

echo
echo    "I can extract the clips now to: `cursegreen`$PWD`cursenorm`"
echo    "By running: `cursecyan`extract_marked_clips_from_video \"$VIDEOFILE\" $*`cursenorm`"
echo -n "Would you like me to do that? `curseyellow`[Y/n]`cursenorm`"

read DECISION
echo

[ ! "$DECISION" ] && DECISION=y
case "$DECISION" in
	y|Y)
		extract_marked_clips_from_video "$VIDEOFILE" "$@"
	;;
esac

