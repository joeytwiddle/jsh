if [ "$1" = --help ]
then
	echo "cat <email> | testeximfilter [ <filter_file> ]"
	exit 1
fi

FF="$HOME/.forward"
if [ "$1" ]
then FF="$1"; shift
fi

/usr/sbin/exim -bf "$FF"
