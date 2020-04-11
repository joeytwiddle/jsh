#!/usr/bin/env bash

open_in_existing_vim_on_current_desktop=yes
if [ -n "$SEPARATE" ] || [ -n "$SEP" ]
then open_in_existing_vim_on_current_desktop=""
fi

all_args_escaped="$(escapeargs "$@")"

if [ -n "$VIM_SERVER_NAME" ]
then vim_server_name="$VIM_SERVER_NAME"
fi

## We don't attempt this if we are root, in case the existing vim session is not owned by root.
## (It would be preferable to check properly if the existing session is owned by this user.)
if [ -z "$vim_server_name" ] && [ -n "$open_in_existing_vim_on_current_desktop" ] && [ "$UID" != 0 ]
then
	current_desktop="$(wmctrl -d | grep "[^ ]* *\*" | takecols 1)"
	vim_server_name="desktop-$current_desktop"
fi

if [ -n "$vim_server_name" ]
then
	## I found if I passed --remote but the server was not already open, then vim didn't open the requested file.
	## So we will only pass --remote if the server exists.
	if vim --serverlist | grep -iFx "$vim_server_name" >/dev/null
	then remote="--remote"
	else remote=""
	fi

	all_args_escaped="--servername $vim_server_name $remote $all_args_escaped"
	echo "Opening in server $vim_server_name ..." >&2
fi

#eval "viminxterm ${all_args_escaped}"
eval "gvim ${all_args_escaped}"
