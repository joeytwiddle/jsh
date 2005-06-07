## jsh-help: Commits files to cvs respository, and immediately unlocks them.

# OUT-OF-DATE: jsh-depends: cursebold cursecyan cursegreen curseyellow cursenorm cvsdiff cvsedit cvsvimdiff edit jdeltmp jgettmp jdiff newer error
# jsh-depends-ignore: vimdiff

## If we can leave it out, it lets us resize during run:
# export COLUMNS

## Old handy options for backwards-compatibility; but will probably be removed sometime:
if [ "$1" = "-diff" ]
then
	shift
	deprecated friendlycvscommit "$@"
elif [ "$1" = "-vimdiff" ]
then
	shift
	deprecated cvsvimdiffall "$@"
else

	## Default: just commit quietly, and cvsedit to make files writeable.

	cvs -q commit "$@"
	# | grep -v "^? "
	## caused: "Vim: Warning: Output is not to a terminal"
	cvsedit "$@" 2> /dev/null

fi
