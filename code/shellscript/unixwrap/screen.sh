export SCREEN_RUNNING=true

if test "$*"
then

	unj screen "$@"

else

	echo "For help press: Ctrl+k then ?"
	unj screen -list
	# sleep 1
	unj screen "-e^kk" -a -D -RR "$@"

fi
