#!/bin/sh

## wtf is -f for?  Who uses -f ?!

NAME="$1"
if test "$NAME" = "-f"; then
	FORCE="-f";
	NAME="$2"
fi
LSLINE=`realpath $JPATH/tools/$NAME`

TOOL="$LSLINE";  # `echo "$LSLINE" | after symlnk`
if test "x$TOOL" = "x"; then TOOL="."; fi
# Can't put quotes around the -f "$TOOL" !
if test "x$TOOL" != "x" -a -f $TOOL; then
	printf ""
else
	TOOL="$PWD/$NAME.sh"

	echo "Tool not found.  Please enter $JPATH/code/shellscript/<path>/$NAME.sh"
	echo "Suggested directories:"
	( cd $JPATH/code/shellscript/ &&
	# ls -d `find . -type d | grep -v "/CVS"` )
	# ls -d */ )
	'ls' -d */ )
	read theirpath
	if [ ! "A$theirpath" = "A" ]; then
		TOOL="$JPATH/code/shellscript/$theirpath/$NAME.sh"
		mkdir -p `dirname "$TOOL"`
		echo "Creating new tool $TOOL"
		touch "$TOOL"
		chmod a+x "$TOOL"
		ln -sf "$TOOL" "$JPATH/tools/$NAME"
	else
		exit 1
	fi
fi

echo "$TOOL"
edit $FORCE "$TOOL"

## Actually, in jsh, we might want to do: editandwait $FORCE "$TOOL"

# A quick check to inform the user if this command already exists on system.
# which, where, and whereis are never guaranteed:
# whereis $1
# which $1
# jwhere $1
if jwhich $1 quietly; then
	printf "  overrides "
	jwhich $1
fi
