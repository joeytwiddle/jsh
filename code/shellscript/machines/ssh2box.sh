# echo $0

if test "$1" = ""; then
	echo "ssh2box <user>@<address> [<extra-args>]"
	exit 1
fi

SSHCOM="ssh $@"

if test `hostname -d` = `echo "$1" | afterfirst "\."`; then
	echo "Both on "`hostname -d`": forwarding X session."
	SSHCOM="$SSHCOM -X"
fi

if xisrunning; then
	xterm -title "$@" -e $SSHCOM
else
	$SSHCOM
fi
