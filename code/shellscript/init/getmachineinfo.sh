#!/bin/sh

export JM_DOES_COLOUR=;
export JM_COLOUR_LS=;
export JM_ADVANCED_DU=;

# For portability:
export JM_UNAME=`uname | tr "ABCDEFGHIJKLMNOPQRSTUVWXYZ" "abcdefghijklmnopqrstuvwxyz"`
# export JM_UNAME=`uname | tolowercase`

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
esac
