if [ "$1" = -inxterm ]
then

	shift
	"$@"

	RES="$?"
	echo
	if [ "$RES" = 0 ]
	then echo "Command succeeded."
	else error "Command failed with $RES."
	fi
	echo "Hit <Enter> to close the window."
	read KEY

else

	xterm -e guifyscript -inxterm "$@"

fi
