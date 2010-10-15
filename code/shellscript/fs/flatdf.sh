#!/bin/sh
## jsh-help: Reformats df output to deal with long lines which can throw it off
## jsh-help: Maybe we should be using mtab instead.

## jsh-help: I have started using flatdf instead of df, because any Linux running
## jsh-help: devfs gets given huge device names for IDE disks, making the reformatting
## jsh-help: vital (for line-based scripts anyway).

# # jsh-ext-depends: sed
# # jsh-depends: escapenewlines unescapenewlines columnise
# ## BUG: "line has no spaces" is not enough; it might be a long filename which has spaces!
# df "$@" |
# sed 's+^\([^ ]*\)[ ]*$+\1 JOIN_LINE+' |
# escapenewlines |
# # pipeboth |
# sed 's+ JOIN_LINE\\n+ +g' |
# unescapenewlines |
# columnise

## CONSIDER: Couldn't we just use env COLUMNS=65535 df ... ?  ANSWER: No it doesn't work!



## This approach does not suffer from the BUG above, and has no external dependencies (well grep).
# jsh-ext-depends: grep
df "$@" |
(
	IFS="" ## Don't ignore the important leading spaces when using read
	while read LINE
	do
		if echo "$LINE" | grep "^[ 	]" >/dev/null
		then
			echo "$LASTLINE $LINE"
			LASTLINE=
		else
			[ "$LASTLINE" ] && echo "$LASTLINE"
			LASTLINE="$LINE"
		fi
	done
	[ "$LASTLINE" ] && echo "$LASTLINE"
)
