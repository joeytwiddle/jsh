## simple_init expects something like the following when it is run:

##  SERVICE_NAME=ut_server
##  WORKING_DIR="/home/oddjob2/ut_server"
##  RUNASUSER="oddjob2"
##
##  start_service () {
##  	sh ./joeys_start_server.sh start
##  	tail -f ut-server/Logs/ucc.init
##  }
##
##  stop_service () {
##  	sh ./joeys_start_server.sh stop
##  }
##
##  check_service () {
##  	findjob ucc.bin
##  }
##
##  . /home/joey/j/tools/simple_init



## What about: support a start_service which bg/inscreen's the process itself, then reports success or failure back to simple_init.
##             (Current default to inscreendo/bg automatically, means we return 0 immediately.)



## If possible, don't we want this to automatically track the PID?
## This script won't be that simple really, cos it will accept various options.
## Eg. default or custom stopping; start in screen or bg or what?

## BUG FIXED: -inner was called in a screen for everything; but only needed for start.

change_to_wd () {
	if [ "$WORKING_DIR" ]
	then
		if ! cd "$WORKING_DIR"
		then
			echo "Failed to: cd \"$WORKING_DIR\"!" >&2
			exit 2
		fi
	fi
}

if [ "$1" = -start ]
then

	shift
	start_service

elif [ "$1" = -done-su ]
then

	shift
	change_to_wd
	case "$1" in
		start)
			[ "$SERVICE_NAME" ] || export SERVICE_NAME=`basename "$0"`
			/home/joey/j/jsh inscreendo "$SERVICE_NAME" "$0" -start "$@"
		;;
		stop)
			stop_service
		;;
		status)
			check_service
		;;
		--help)
			echo
			echo "A simple init script."
			echo
			echo "Required:"
			declare -f start_service
			declare -f stop_service
			declare -f check_service
			echo
			echo "Optional:"
			echo "SERVICE_NAME=$SERVICE_NAME"
			echo "WORKING_DIR=$WORKING_DIR"
			echo "RUNASUSER=$RUNASUSER"
			echo
			exit 1
		;;
		*)
			echo "Sorry, no implementation of: $1"
			exit 1
		;;
	esac

else

	if [ "$RUNASUSER" ] && [ "$UID" = 0 ]
	then
		su $RUNASUSER -c "$0 -done-su $*"
		exit
	else ## Should really check that, since we aren't root, we are the right user (if any is specified).  (If none is specified, then I guess we can assume anyone can run this service; although if root does it might be a security risk.)
		"$0" -done-su "$@"
	fi

fi



