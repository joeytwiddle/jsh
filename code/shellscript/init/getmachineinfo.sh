#!/bin/sh

## Interesting, on Hwi:
## zsh gives MACHTYPE=i686
## bash gives MACHTYPE=i386-pc-linux-gnu

export JM_DOES_COLOUR=;
export JM_COLOUR_LS=; # deprecated in favour of:
export JM_LS_OPTS=;
export JM_ADVANCED_DU=;

export JM_UNAME=`
# For portability:
	uname | tr "ABCDEFGHIJKLMNOPQRSTUVWXYZ" "abcdefghijklmnopqrstuvwxyz" |
#	uname | tolowercase |
	sed "s/_.*//"
`

case "$JM_UNAME" in
	"linux")
		JM_DOES_COLOUR=true
		JM_COLOUR_LS=true
		JM_ADVANCED_DU=true
		JM_LS_OPTS="-F --color -b"
	;;
	"sunos")
		JM_DOES_COLOUR=true
		JM_LS_OPTS="-F -b"
	;;
	"hp-ux")
		JM_DOES_COLOUR=true
		JM_LS_OPTS="-F -b"
	;;
	"cygwin")
		JM_DOES_COLOUR=true
		JM_COLOUR_LS=true
		JM_ADVANCED_DU=true
		JM_LS_OPTS="-F -b"
	;;
	*)
		echo "getmachineinfo: Do not know $JM_UNAME, so not setting any advanced features."
	;;
esac
