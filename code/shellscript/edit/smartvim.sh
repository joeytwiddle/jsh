#!/usr/bin/env bash
set -e

# Opens gvim or viminxterm, reusing an existing vim session for the repository or the desktop when appropriate

all_args_escaped="$(escapeargs "$@")"

if [ -n "$SEPARATE" ] || [ -n "$SEP" ]
then vim_server_name=""
else
	# Open in a common session for this git repository
	if [ -z "$vim_server_name" ]
	then
		git_toplevel="$(git rev-parse --show-toplevel 2>/dev/null)" || true
		[ -n "$git_toplevel" ] && vim_server_name="$(basename "$git_toplevel")"
	fi

	# Open in a common session for this desktop
	## We don't attempt this if we are root, in case the existing vim session is not owned by root.
	## (It would be preferable to check properly if the existing session is owned by this user.)
	if [ -z "$vim_server_name" ] && [ "$UID" != 0 ] && which wmctrl >/dev/null 2>&1
	then
		current_desktop="$(wmctrl -d | grep "[^ ]* *\*" | takecols 1)"
		vim_server_name="desktop-$current_desktop"
	fi
fi

# Open in the session selected by the user
[ -n "$SESSION" ] && vim_server_name="$SESSION"

if [ -n "$vim_server_name" ]
then
	# I found if I passed --remote but the server was not already open, then vim didn't open the requested file.
	# So we will only pass --remote if the server exists.
	if vim --serverlist | grep -iFx "$vim_server_name" >/dev/null
	then remote="--remote"
	else remote=""
	fi

	all_args_escaped="--servername $vim_server_name $remote $all_args_escaped"
	echo "Opening in server $vim_server_name ..." >&2
fi

#eval "exec viminxterm ${all_args_escaped}"
eval "exec gvim ${all_args_escaped}"
