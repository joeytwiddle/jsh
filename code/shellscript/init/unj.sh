#!/bin/sh
## jsh-help: unj <program> <args> runs the version of <program> outside of jsh, when otherwise (without unj) the jsh override version of <program> might have been run.
## jsh-help: The -quiet option will supress error messages if the <program> does not exist outside jsh, but at time of writing, there were no uses of it in jsh, and it seems pretty daft anyway, so I recommend this option should be removed.

# jsh-depends: jwhich
# this-script-does-not-depend-on-jsh: exists jsh startj-hwi

## Should unj deprecate jwhich?
## Note: Both are dangerous because if X calls unj X but unj X return the same X then infinite loop :-(

## Could be made much simpler.  Just ungrep the path, then run "$@"
## unj used to find and run the version of "$1" on the PATH but not in jsh
## But this method runs _without_ jsh on the PATH:
## Disabled because, at least:  This caused problems with inscreendo and ssh2box, which (during their call to jsh's screen script) wanted to run the external binary (not the jsh script) but wanted the jsh environment available for that screen process.
# NEWPATH=`
# echo "$PATH" | tr : '\n' |
# while read PATHBIT
# do
	# [ ! -f "$PATHBIT"/startj-hwi ] && echo -n "$PATHBIT:"
# done
# `
# PATH="$NEWPATH"
## At time of writing, I think unj is mostly used to run the real version,
## rather than disable jsh entirely.
## So the above method should be made a separate script, then maybe current uses of unj could be refactored to "extjshrun"

if test "$1" = "-quiet"
then shift; UNJ_QUIET=true
fi
PROG="$1"
shift
REALPROG=`jwhich "$PROG"`
# REALPROG="$PROG"
if test "$REALPROG"
then
	"$REALPROG" "$@"
else
	if test ! "$UNJ_QUIET"
	then
		INJ=`which "$PROG"`
		if test "$INJ"
		then echo "unj: $PROG exists in jsh but not outside it"
		else echo "unj: $PROG does not exist in jsh or in your PATH"
		fi
	fi
	exit 1
fi
