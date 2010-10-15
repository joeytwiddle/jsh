#!/bin/sh
## We try to use Lynx where possible because some sites reject wget requests :-(
## TODO: Set wget's Agent header.

if `jwhich lynx -quietly`
then lynx -source "$@"
elif `jwhich wget -quietly`
then wget -nv -O - "$@"
else
	error "downloadurl: neither wget nor lynx present, no telnet implemented."
	exit 1
fi
