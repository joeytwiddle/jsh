#!/bin/bash
## BUG: doesn't work if you use a sound server (eg. artsd or esd).  Fixing that would probably require a different approach.

# tail -n 1 $JPATH/logs/xmms.log | afterlast ">" | beforelast "<"

find_open_music_files () {

	(
		# for DEV in /dev/dsp /dev/sound/dsp
		# do [ -e $DEV ] && fuser -v $DEV 2>&1
		# done |
		# # drop 2 | ## why did you want to drop 2?  i have only 1 header line :P
		# drop 1 |
		# # takecols 5 |
		# dropcols 1 2 3 4 | ## only the first line has something in first column, so this works better
		# This should be merged with nextsong's whichmediaplayers into list_running_media_processes
		listopenfiles -allthreads xmms 2>/dev/null | grep "\(/dev/dsp\|/dev/snd/.\)" | grep -v "/dev/snd/control" | head -n 1 | takecols 1 |
		grep . ||
		listopenfiles -allthreads . 2>/dev/null | grep "\(/dev/dsp\|/dev/snd/.\)" | grep -v "/dev/snd/control" | takecols 1
		## TODO: on some systems listopenfiles (lsof) runs slowly
		##       this can be helped by specifying the process name to look for
	) |

	removeduplicatelines |
	trimempty |

	while read PROGNAME
	do

		# jshinfo "$PROGNAME"

		## Yep some systems use bin others sbin.
		## -c is fast! :D
		/usr/*bin/lsof -c "$PROGNAME" 2>/dev/null |

		## Negative match: (could be confirmed later eg. by file)
		# grep -v /lib/ |
		# grep -v "\(/tmp\|/dev/null\|/usr/bin/xmms\|/dev/dsp.\|/dev/pts.\|/dev/pts..\|pipe\|socket\|/\|/tmp/xmms_[^ ]*\)$" |

		## Positive match:
		grep -i '\.\(mp3\|ogg\|avi\|mov\|wav\|pcm\|raw\|mpg\|mpeg\|rm\|wmv\|mod\|xm\)$' |

		# pipeboth |

		dropcols 1 2 3 4 5 6 7 8 |
		removeduplicatelines

	done
}

FILES=` find_open_music_files `

OUTPUT=`

	## For compatibility with randommp3 script:
	if ( [ "$FILES" = /tmp/randommp3-gainchange.mp3 ] || [ "$FILES" = /tmp/randommp3-gainchange-2.mp3 ] ) && [ -e "$FILES.whatsplaying" ]
	then
		jshinfo "[whatsplaying] Got back "$FILES" so reading $FILES.whatsplaying instead:"
		ls -l "$FILES.whatsplaying" | dropcols 1 2 3 4 5 6 7 8 9 10
	else
		echo "$FILES"
	fi |
	removeduplicatelines ## because, at least, mplayer opens the file in two threads/processes

`

echo "$OUTPUT"

if [ ! "$NOEXTRAS" ] && xisrunning && which osd_cat >/dev/null && [ -z "$SKIP_OSD" ] 2>&1
then
	(
		echo "$OUTPUT" |
		head -n 1 |
		foreachdo showsonginfo
		## No good putting these in parallel - they kill each other :P
	) >&2
fi

