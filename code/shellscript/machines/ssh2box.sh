# echo $0
## TODO: check: if our exported JPATH gets passed across the connection, it'd probably be better to clear it

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
if [ "$DOMAIN" = `echo "$1" | afterfirst "\."` ]
then
	echo "Both on $DOMAIN: forwarding X session."
	SSHCOM="$SSHCOM -X"
fi

if jwhich screen quietly
then
	while [ "$2" ]; do shift; done
	# SCRNAME="$1"
	SCRNAME="sshs"
	export SCREENNAME="$SCRNAME"
	SCRSES=`screen -list | grep "$1" | head -1 | takecols 1`
	if [ "$SCRSES" ]
	then
		echo "Rejoining screen $SCRSES with $SSHCOM"
		screen -S $SCRSES -X screen $SSHCOM
		# SSHCOM="screen -DDR -S $SCRSES"
		SSHCOM="screen -R -S $SCRSES"
	else
		SSHCOM="screen -h 10000 -a -e^s^l -S $SCRNAME $SSHCOM"
	fi
fi

if xisrunning
then
	# xterm -bg "#500000" -title "$TITLE" -e $SSHCOM &
	# MC: xterm -bg "#003800" -title "$TITLE" -e $SSHCOM &
	xterm -bg "#002000" -title "$TITLE" -e $SSHCOM &
else
	xttitle "$TITLE"
	$SSHCOM
fi
