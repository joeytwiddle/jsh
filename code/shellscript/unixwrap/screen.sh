export SCREEN_RUNNING=true

if test "$*"
then

	unj screen "$@"

else

	unj screen -list
	echo "Special char is Ctrl+k, help is Ctrl+k then ?"
	sleep 2
	unj screen "-e^kk" -a -D -RR "$@"

fi
