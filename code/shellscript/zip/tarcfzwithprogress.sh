#!/bin/sh
# alias gzip=bzip2

TARGETARCHIVE="$1"
shift

TOTALSIZEOFFILES=`
	## CONSIDER: using -c to du
	du -sb "$@" |
	takecols 1 |
	awksum
`
## TODO: this sum appears to be a bit short (presumably because it counts data only, not the size of file meta-data (filename, perms etc.), or tar's headers).

## TODO: versus tar cfz, this produces slightly different results.  Was it just file meta-data that had changed between the two runs, or does tar cfz perform a non-default gzip or is it different in some other way?
tar c "$@" |
catwithprogress -size "$TOTALSIZEOFFILES" |
gzip -c > "$TARGETARCHIVE"
