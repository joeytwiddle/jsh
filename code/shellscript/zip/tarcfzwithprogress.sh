TARGETARCHIVE="$1"
shift

TOTALSIZEOFFILES=`
	du -sb "$@" |
	takecols 1 |
	awksum
`
## TODO: this sum is a bit short because it counts data only, not the size of file meta-data (filename, perms etc.), or tar's headers.

## TODO: versus tar cfz, this produces slighttly different results.  Was it just file meta-data that had changed between the two runs, or does tar cfz perform a non-default gzip or is it different in some other way?
tar c "$@" |
catwithprogress -size "$TOTALSIZEOFFILES" |
gzip -c > "$TARGETARCHIVE"
