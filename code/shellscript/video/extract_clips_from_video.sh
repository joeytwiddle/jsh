## TODO: allow interactive labelling of marks -> filename, or optionally undo the last unwanted mark.

CLIPMARKERFILE=/tmp/clipmarkers.txt

if [ ! "$1" ] || [ "$1" = --help ]
then
more << !

generate_clip_markers <video_file>

  will play the video file in mplayer, and allow you to mark the positions of
  clips you want to extract.

  This can be useful to get small files out of a large video before importing
  the clips to a video editing package.

  The script watches for whenever you pause the playback (by pressing <SPACE>).

  The first time you pause marks the beginning of a clip you want to extract
  (an In_Mark).

  The second time marks the end of the clip (an Out_Mark), and the two
  timepoints are written to a file.

  By default the marked points are stored in the file $CLIPMARKERFILE

  If you accidentally mark an unwanted In_Mark, you should mark the
  corresponding Out_Mark and then delete the last line from the file.

  The format of the video file will influence the accuracy of the marked time
  points.  To be safe, make longer clips than you need, with a gap at each end.

!
exit 1
fi

VIDEOFILE="$1"

## Backup the marker file in case you realise u wanted an older one!
[ -f "$CLIPMARKERFILE" ] && which rotate >/dev/null && rotate -nozip $CLIPMARKERFILE

echo
curseyellow

MARKERTYPE=In_Mark
LASTMARKERPOS=not_yet_set

mplayer "$VIDEOFILE" 2>&1 |

# sed 's++'`echo`'+g' |

tr '' '\n' |

while read LINE
do

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

		echo "Got $MARKERTYPE at $MARKERPOS"

		if [ "$MARKERTYPE" = Out_Mark ]
		then
			echo "$LASTMARKERPOS	$MARKERPOS" >> $CLIPMARKERFILE
			MARKERTYPE=In_Mark
		else
			LASTMARKERPOS=$MARKERPOS
			MARKERTYPE=Out_Mark
		fi

	fi

done

cursenorm

echo
echo "Clip markers have been stored in `cursecyan`$CLIPMARKERFILE`cursenorm`"

echo
echo    "I can extract the clips now to:"
echo    "  `cursegreen`$PWD`cursenorm`"
echo -n "Do you want to extract the clips now? `curseyellow`[Y/n]`cursenorm` "

read DECISION
echo

[ ! "$DECISION" ] && DECISION=y
case "$DECISION" in
	y|Y)
		extract_marked_clips_from_video "$VIDEOFILE"
	;;
esac

