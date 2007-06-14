[ "$1" ] && echo "$*" | getnumber ||
# Takes a number from the front of the stream.
sed 's/[^0123456789\.].*//'
