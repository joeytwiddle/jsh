#!/bin/sh

export JM_DOES_COLOUR=;
export JM_COLOUR_LS=;
export JM_ADVANCED_DU=;

export JM_UNAME=`uname`

case "$JM_UNAME" in
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
