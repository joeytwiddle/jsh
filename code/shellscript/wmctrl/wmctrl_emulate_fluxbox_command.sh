#!/bin/bash

## From: http://sourceforge.net/tracker/?func=detail&aid=3190205&group_id=35398&atid=413960

if [[ -z "$1" ]]; then
	exit 1
fi

case "$1" in
	":Workspace")
		target_workspace=$(($2-1))
		;;
	":RightWorkspace")
		target_workspace=$(wmctrl -d | grep -A1 '[[:digit:]]\+ \+\*' | tail -n 1 | cut -f1 -d ' ')
		;;
	":LeftWorkspace")
		target_workspace=$(wmctrl -d | grep -B1 '[[:digit:]]\+ \+\*' | head -n 1 | cut -f1 -d ' ')
		;;
	":NextWorkspace")
		wsps=$(wmctrl -d | grep -A1 '[[:digit:]]\+ \+\*')
		case $(echo "$wsps" | wc -l) in
			1)
				target_workspace=$(wmctrl -d | head -n 1 | cut -f1 -d ' ')
				;;
			2)
				target_workspace=$(echo "$wsps" | tail -n 1 | cut -f1 -d ' ')
				;;
			*)
				echo "Weird wc output" > /dev/stderr
				exit 1
				;;
		esac
		;;
	":PrevWorkspace")
		wsps=$(wmctrl -d | grep -B1 '[[:digit:]]\+ \+\*')
		case $(echo "$wsps" | wc -l) in
			1)
				target_workspace=$(wmctrl -d | tail -n 1 |
				cut -f1 -d ' ')
				;;
			2)
				target_workspace=$(echo "$wsps" | head -n
				1 | cut -f1 -d ' ')
				;;
			*)
				echo "Weird wc output" > /dev/stderr
				exit 1
				;;
		esac
		;;
	*)
		echo "Command $1 not yet implemented" > /dev/stderr
		exit 1
		;;
esac

wmctrl -s $target_workspace

