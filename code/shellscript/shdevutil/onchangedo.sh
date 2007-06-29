verbosely eval "$@"
touch $$.lastdone

while true
do

	# FILES=`echolines "$@" | filesonly`
	FILES=`echolines $* | filter_list_with test -e`

	[ "$FILES" ] || FILES=". -maxdepth 1"

	# if find "$@" -newer $$.lastdone
	if find $FILES -newer $$.lastdone | higrep . | grep .
	then
		verbosely eval "$@"
		touch $$.lastdone
	else
		# verbosely sleep 10
		sleep 3
	fi

done
