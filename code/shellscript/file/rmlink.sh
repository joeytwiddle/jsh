#!/bin/sh
## jsh-help: removes symlink(s), or produces error if non-symlink was provided

## Like 'rmdir' which only works on directories (folders), rmlink only works on symlinks.

## TODO CONSIDER: should rmlink return true if target does not exist (already rm-ed)?
##                It might be fitting to do whatever rmdir does.

for FILE
do

	## This check is the whole point of rmlink
	## Even if most of the time we call this script on symlinks only,
	## some scripts want to do that safely, and so call this script.
	## However, at the moment an error is only returned if the last file was not a symlink
	if [ -L "$FILE" ] && issymlink "$FILE"
	then rm "$FILE"
	else
		jshwarn "$FILE is not a symlink!" ## This check is important
		# false ## for return value, but only works on the *last* file at the moment
		## I abandoned the exitcode idea, because I find myself using this script on non-links quite a lot.
		## E.g. I do rmlink ./* to clear all the links in the current folder, and leave the other files untouched.
	fi

done
