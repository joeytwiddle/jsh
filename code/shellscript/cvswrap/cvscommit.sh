#!/bin/bash
## jsh-help: Commits files to cvs respository, and immediately unlocks them.

# OUT-OF-DATE: jsh-depends: cursebold cursecyan cursegreen curseyellow cursenorm cvsdiff cvsedit cvsvimdiff edit jdeltmp jgettmp jdiff newer error
# jsh-depends-ignore: vimdiff

## If we can leave it out, it lets us resize during run:
# export COLUMNS

## Old handy options for backwards-compatibility; but will probably be removed sometime:
if [ "$1" = "-diff" ]
then
	shift
	deprecated -by "$0" friendlycvscommit "$@"
elif [ "$1" = "-vimdiff" ]
then
	shift
	deprecated -by "$0" cvsvimdiffall "$@"
else

	## Default: just commit quietly, and cvsedit to make files writeable.

	cvs -q commit "$@"
	errNo="$?"
	# | grep -v "^? "
	## caused: "Vim: Warning: Output is not to a terminal"
	## CONSIDER: Should we do cvsedit if there was an error?
	cvsedit "$@" >/dev/null 2>&1
	exit "$errNo"

fi
