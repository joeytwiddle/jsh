## Not equivalent to:
# tr "\n" "\000" | xargs -0 "$@"

## xmode can be used like this:
# find . -type f -not -size 0 | foreachdo -x mv \"\$X\" ..
## poo huh?
if [ "$1" = -x ]
then XMODE=true; shift
fi

while read LINE
do
	if [ "$XMODE" ]
	then
		export X="$LINE"
		echo "$*" | sh
	else
		"$@" "$LINE"
	fi
done
