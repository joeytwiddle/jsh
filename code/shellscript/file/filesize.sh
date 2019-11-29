#!/bin/sh
# jsh-depends-ignore: find
# jsh-ext-depends-ignore: find
# jsh-depends: takecols
## TODO: trim this down: remove -likecksum / put it elsewhere; and consider using find -maxdepth 0 -printf "%s" to avoid spawning another process
if test "$1" = "-likecksum"; then
	shift
	'ls' -l "$@" |
		grep -v "^total " |
		while read PERM INODE OWNER GROUP SIZE DM DD TIME FILENAME; do
			echo "0 $SIZE	$FILENAME"
		done
else
	## Doesn't work on symlinks; sometimes breaks on weird names (like --) in ut maps?)
	# 'ls' -l "$@" |
		# takecols 5
	## this also breaks: find: invalid predicate `)Starship.unr'
	#find "$@" -maxdepth 0 -follow -printf "%s\n"
	stat -c '%s' "$@"
	# Sadly that stat command does not work on macOS
	# https://unix.stackexchange.com/questions/16640/how-can-i-get-the-size-of-a-file-in-a-bash-script
	# This should be POSIX compatible:
	#du -b "$filename" | cut -f1
fi
