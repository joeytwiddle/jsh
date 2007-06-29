## This is useful for opening .wvx files,
## which appear to be xml formatted pointers to mms:// video streams.

## TODO: may need -playlist sometimes, dunno, can we always add this option?  NO!
## DONE: I got an asx whose /only/ content was an mms: URL, so it failed the regexp below!  (OK so now I just use extracturls)

# jsh-ext-depends: mplayer
# jsh-depends: extracturls removeduplicatelines withalldo mplayer verbosely
## extractregex

FILE="$1"

PROTOCOLS="(mms|rtsp)"

cat "$FILE" |
# extractregex '"(mms:\/\/[^"]*)"' |
# extractregex -atom "[\"']($PROTOCOLS:\/\/[^\"']*)[\"']" |
extracturls | egrep "^$PROTOCOLS:" |

removeduplicatelines |
withalldo verbosely mplayer

