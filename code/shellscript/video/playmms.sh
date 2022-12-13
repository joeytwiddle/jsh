## This is useful for opening .wvx files,
## which appear to be xml formatted pointers to mms:// video streams.
## But you can also use it to extract rtsp:// urls from .ram files, since we
## simply extract matching regexps.

## TODO: may need -playlist sometimes, dunno, can we always add this option?  NO!
## DONE: I got an asx whose /only/ content was an mms: URL, so it failed the regexp below!  (OK so now I just use extracturls)

# jsh-ext-depends: mplayer
# jsh-depends: extracturls removeduplicatelines withalldo mplayer verbosely
## extractregex

FILE="$1"

# Originally intended for mms and rtsp, but works equally well on streaming
# radio .m3u files which offer http URLs.
PROTOCOLS="(mms|rtsp|http)"

cat "$FILE" |
# extractregex '"(mms:\/\/[^"]*)"' |
# extractregex -atom "[\"']($PROTOCOLS:\/\/[^\"']*)[\"']" |
extracturls | grep -E "^$PROTOCOLS:" |
removeduplicatelines |

# pipeboth |
# withalldo verbosely mplayer

tee /tmp/mms.list
mplayer -playlist /tmp/mms.list

