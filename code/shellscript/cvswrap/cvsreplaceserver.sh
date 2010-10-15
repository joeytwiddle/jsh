#!/bin/sh
if test "$2" = ""; then
	echo "cvsreplaceserver <original_server_name> <new_server_name>"
	exit 1
fi

sedreplace "$1" "$2" `find . -name "Root"`
