#!/bin/sh

export JM_DOES_COLOUR=;
export JM_COLOUR_LS=;
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
	;;
	"sunos")
		JM_DOES_COLOUR=true
	;;
	"hp-ux")
		JM_DOES_COLOUR=true
	;;
	"cygwin")
		JM_DOES_COLOUR=true
		JM_COLOUR_LS=true
		JM_ADVANCED_DU=true
	;;
	*)
		echo "getmachineinfo: Do not know $JM_UNAME, so not setting any advanced features."
	;;
esac
