#!/bin/sh

UNAME=`uname`

case "$UNAME" in
	"Linux")
		JM_DOES_COLOUR=true
		JM_COLOUR_LS=true
		JM_ADVANCED_DU=true
		;;
	"SunOS")
		JM_DOES_COLOUR=true
      ;;
	"HP-UX")
		JM_DOES_COLOUR=true
		;;
esac

export JM_DOES_COLOUR;
export JM_COLOURLS;
export JM_ADVANCED_DU;
