## Is the -S really neccessary?

if [ "$1" = -remote ]
then
	shift

	## Works for remote screen:
	[ "$TERM" = screen ] && echo -n "k$*\\" >&2 # does this work? not as part of bash prompt!

else

	## Only works on local screen:
	[ "$STY" ] && screen -S "$STY" -X title "$*"

fi

## We probably want the former more commonly, so local screens update local display.
## However if ssh2box does not set the title before ssh'ing, the latter passthrough method would be useful
## for the remote jsh to see TERM=screen but STY="", so passthrough the name of the machine and be done with.
