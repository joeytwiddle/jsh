#!/bin/bash
## BUG: doesn't work if you use a sound server (eg. artsd or esd).  Fixing that would probably require a different approach.

# tail -n 1 $JPATH/logs/xmms.log | afterlast ">" | beforelast "<"

audio_file_extensions_regexp='\.\(mp3\|ogg\|wav\|pcm\|raw\|mpg\|mpeg\|avi\|mov\|m4a\|rm\|wmv\|wma\|mod\|xm\|it\|flv\|asf\)$'
# \|mp4

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

		## BUG: If mplayer is using pulseaudio (or any separate soundsystem) then the pulseaudio process is listed, but not the mplayer process.
		## This is a quickfix, although only for mplayer!  (We could list a number of known audio players here...)
		echo "mplayer"
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
		grep -i "${audio_file_extensions_regexp}" |

		# pipeboth |

		dropcols 1 2 3 4 5 6 7 8 |
		removeduplicatelines

	done
}

FILES="$(listfilesopenby mplayer | dropcols 1 2 | grep "${audio_file_extensions_regexp}")"

[ -z "$FILES" ] && FILES=` find_open_music_files `

FILES=`

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

# whatsplaying prints out the file that was found.
# So script can do things like: ln -s "`whatsplaying`" ~/stuff/music/for/steve/
printf "%s\n" "$FILES"

#echo "[whatsplaying] FILES: $FILES"

if [ ! "$NOEXTRAS" ] && xisrunning && which osd_cat >/dev/null && [ -z "$SKIP_OSD" ] 2>&1
then
	(
		echo "$FILES" |
		head -n 1 |
		foreachdo showsonginfo 2>/dev/null
		## No good putting these in parallel - they kill each other :P
	) >&2
fi

