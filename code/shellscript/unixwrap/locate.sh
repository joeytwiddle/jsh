if test "$1" = ""; then
	echo "locate [ -nh ] <regex>"
	exit 1
fi

if test "$1" = "-nh"; then
	shift
	`jwhich locate` "$1"
else
	`jwhich locate` "$1" |
	highlight "$@"
fi
