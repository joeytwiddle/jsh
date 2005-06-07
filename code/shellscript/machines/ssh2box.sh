# echo $0
## TODO: check: if our exported JPATH gets passed across the connection, it'd probably be better to clear it

if [ "$1" = "" ] || [ "$1" = --help ]
then
	echo "ssh2box <user>@<address> [<extra-args>]"
	exit 1
fi

if [ "$1" = -pause ]
then
	shift
	"$@"
	echo -n "Stream ended; press <Enter>." >&2
	read KEY
	exit
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
	SSHCOM="ssh2box -pause $SSHCOM"
	# # while [ "$2" ]; do shift; done
	# # SCRNAME="$1"
	# SCRNAME="boxen"
	# export SCREENNAME="$SCRNAME"
	# SCRSES=`screen -list | grep "$SCRNAME" | head -n 1 | takecols 1`
	# ## TODO: try doing: inscreendo $SSHCOM
	# if [ "$SCRSES" ]
	# then
		# if [ "$SCRSES" = "$STY" ]
		# then
			# SSHCOM="screen -X screen $SSHCOM"
			# echo "Inside $SCRNAME already, so just running $SSHCOM"
		# else
			# echo "Rejoining screen $SCRSES with $SSHCOM"
			# screen -S $SCRSES -X screen $SSHCOM
			# ## I have seen this applied to wrong window - I think it happens if there we occupied a spare window slot, as opposed to a new one on the right.
			# ## Trying this to prevent it:
			# sleep 2
			# screen -S $SCRSES -X title ">$*>"
			# # SSHCOM="screen -DDR -S $SCRSES"
			# SSHCOM="screen -D -R $SCRSES -S $SCRSES"
		# fi
	# else
		# SSHCOM="screen -h 10000 -a -e^k^l -S $SCRNAME $SSHCOM"
	# fi
	inscreendo -xterm boxen $SSHCOM
else
	jshwarn "Cannot start sshi in screen, because you don't have screen!"
	"$SSHCOM"
fi

# if xisrunning
# then
	# # xterm -bg "#500000" -title "$TITLE" -e $SSHCOM &
	# # MC: xterm -bg "#003800" -title "$TITLE" -e $SSHCOM &
	# xterm -bg "#002000" -title "$TITLE" -e $SSHCOM &
# else
	# xttitle "$TITLE"
	# $SSHCOM
# fi
