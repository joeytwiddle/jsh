#!/bin/sh

NAME="$1"

TOOL="$(realpath "$JPATH/tools/$NAME")"
if ! [ -f "$TOOL" ]
then TOOL="$(which "$NAME")"
fi
if [ -f "$TOOL" ]
then : # OK, got it
else
	TOOL="$PWD/$NAME.sh"

	echo "Tool not found.  To create, enter $JPATH/code/shellscript/<path>/$NAME.sh"
	sleep 1
	echo "Suggested directories:"
	sleep 2   ## Pause so messages don't scroll away too fast!
	(
		cd "$JPATH/code/shellscript/" &&
		# ls -d `find . -type d | grep -v "/CVS"` )
		# ls -d */ )
		'ls' -d */
	)
	read theirpath
	if [ -n "$theirpath" ]
	then
		TOOL="$JPATH/code/shellscript/$theirpath/$NAME.sh"
		mkdir -p `dirname "$TOOL"`
		echo "Creating new tool $TOOL"
		#touch "$TOOL"
		echo '#!/bin/sh' > "$TOOL"
		echo '#!/usr/bin/env bash' >> "$TOOL"
		echo 'set -e' >> "$TOOL"
		chmod a+x "$TOOL"
		ln -sf "$TOOL" "$JPATH/tools/$NAME"
	else
		exit 1
	fi
fi

echo "$TOOL"

current_desktop="$(command -v wmctrl >/dev/null && wmctrl -d | grep "[^ ]* *\*" | takecols 1)"
if [ -n "$current_desktop" ]
then export vim_server_name="TOOLS@${current_desktop}"
else export vim_server_name="TOOLS"
fi

# jsh edit "$TOOL"

if xisrunning
then editandwait "$TOOL" &
else editandwait "$TOOL"
fi

# A quick check to inform the user if this command already exists on the system
if jwhich "$1" quietly
then
	printf "  overrides "
	jwhich "$1"
fi
