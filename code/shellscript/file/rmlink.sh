## jsh-help: removes symlink(s), or produces error if non-symlink was provided

## TODO CONSIDER: should rmlink return true if target does not exist (already rm-ed)

for FILE
do

	## This check is the whole point of rmlink
	## Even if most of the time we call this script on symlinks only,
	## some scripts want to do that safely, and so call this script.
	## However, at the moment an error is only returned if the last file was not a symlink
	if [ -L "$FILE" ] && issymlink "$FILE"
	then rm "$FILE"
	else
		error "$FILE is not a symlink!" ## This check is important
		false ## for return value, but only works on the *last* file at the moment
	fi

done
