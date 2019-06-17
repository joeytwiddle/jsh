verbosely eval "$@"

timerfile="/tmp/onchangedo.$USER.$$"
touch "$timerfile"

while true
do

	# FILES=`echolines "$@" | filesonly`
	FILES=`echolines $* | filter_list_with test -e`

	[ "$FILES" ] || FILES=". -maxdepth 1"

	# if find "$@" -newer "$timerfile"
	if find $FILES -newer "$timerfile" | higrep . | grep .
	then
		# This used to be below, but it's better up here
		touch "$timerfile"
		verbosely eval "$@"
	else
		# verbosely sleep 10
		sleep 3
	fi

done
