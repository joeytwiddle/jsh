#!/bin/sh
if [ "$2" = "" ]
then
	echo "cvsreplaceserver <original_server_name> <new_server_name>"
	echo "  e.g.: cvsreplaceserver `cat CVS/Root` :ext:joey@hwi.ath.cx:/stuff/cvsroot"
	exit 1
fi

sedreplace "$1" "$2" `find . -name "Root"`
