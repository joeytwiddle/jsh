# echo $0

if test "$1" = ""; then
	echo "ssh2box <user>@<address> [<extra-args>]"
	exit 1
fi

SSHCOM="ssh -C $@"
TITLE="$*"

## Problem: Unix hostname does not allow this!
SHORTHOSTNAME=`hostname`
## and some machines don't have host
DOMAIN=`host "$SHORTHOSTNAME" | sed "s/[^\.]*\.//;s/ .*//"`
## TODO: change this rule to: don't forward X if going to or from hwi (ie. across a laggy connexion)
if test "$DOMAIN" = `echo "$1" | afterfirst "\."`; then
	echo "Both on $DOMAIN: forwarding X session."
	SSHCOM="$SSHCOM -X"
fi

if xisrunning; then
	# xterm -bg "#500000" -title "$TITLE" -e $SSHCOM &
	# MC: xterm -bg "#003800" -title "$TITLE" -e $SSHCOM &
	xterm -bg "#002000" -title "$TITLE" -e $SSHCOM &
else
	xttitle "$TITLE"
	$SSHCOM
fi
