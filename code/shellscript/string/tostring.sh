# More like toline

# fromstring -tostring "$@"

## Now implemented more efficiently:

while read LINE
do
	if test "$LINE" = "$*"
	then
		exit 0
		## sh should drop the stream rather than cat the rest (could be bad if long)
	fi
	echo "$LINE"
done
