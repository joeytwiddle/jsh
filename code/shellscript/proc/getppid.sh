if test "$1" = ""; then
	echo 'getppid $$'
	echo '	gets parent id of current shell'
	echo 'getppid <pid>'
	echo '	gets parent id of process <pid>'
	exit 1
fi

myps -A | takecols 2 3 | grep " $1$" | takecols 1

