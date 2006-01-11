TARGETARCHIVE="$1"
shift

catwithprogress "$TARGETARCHIVE" |
tar xz
