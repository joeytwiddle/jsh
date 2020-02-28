#!/bin/sh

NAME="$1"
LSLINE=`realpath $JPATH/tools/$NAME`

TOOL="$LSLINE";  # `echo "$LSLINE" | after symlnk`
if test "x$TOOL" = "x"; then TOOL="."; fi
# Can't put quotes around the -f "$TOOL" !
if test "x$TOOL" != "x" -a -f $TOOL; then
	printf ""
else
	TOOL="$PWD/$NAME.sh"

	echo "Tool not found.  To create, enter $JPATH/code/shellscript/<path>/$NAME.sh"
	sleep 1
	echo "Suggested directories:"
	sleep 2   ## Pause so messages don't scroll away too fast!
	( cd $JPATH/code/shellscript/ &&
	# ls -d `find . -type d | grep -v "/CVS"` )
	# ls -d */ )
	'ls' -d */ )
	read theirpath
	if [ ! "A$theirpath" = "A" ]; then
		TOOL="$JPATH/code/shellscript/$theirpath/$NAME.sh"
		mkdir -p `dirname "$TOOL"`
		echo "Creating new tool $TOOL"
		#touch "$TOOL"
		echo '#!/bin/sh' > "$TOOL"
		echo '#!/usr/bin/env bash' >> "$TOOL"
		chmod a+x "$TOOL"
		ln -sf "$TOOL" "$JPATH/tools/$NAME"
	else
		exit 1
	fi
fi

echo "$TOOL"

current_desktop="$(command -v wmctrl >/dev/null && wmctrl -d | grep "[^ ]* *\*" | takecols 1)"
if [ -n "$current_desktop" ]
then export VIM_SERVER_NAME="TOOLS@${current_desktop}"
else export VIM_SERVER_NAME="TOOLS"
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
