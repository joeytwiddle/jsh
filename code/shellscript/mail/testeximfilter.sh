if [ "$1" = --help ]
then
	echo "cat <email> | testeximfilter [ -results ] [ <filter_file> ]"
	echo "  or try"
	echo "cat <mbox> | formail -s testeximfilter ..."
	exit 1
fi

if [ "$1" = -results ]
then

	shift
	testeximfilter "$@" |
	## TODO: what about deliveries?!
	# cat
	grep "^Save message to: " |
	afterfirst ": "

else

	FILTER_FILE="$HOME/.forward"
	if [ "$1" ]
	then FILTER_FILE="$1"; shift
	fi

	/usr/sbin/exim -bf "$FILTER_FILE"

fi
