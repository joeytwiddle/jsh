## jsh-help: removes symlink(s), or produces error if non-symlink was provided

for FILE
do

	## Double-checking!!
	if [ -L "$FILE" ] && issymlink "$FILE"
	then
		rm "$FILE"
	else
		error "$FILE is not a symlink!"
	fi

done
