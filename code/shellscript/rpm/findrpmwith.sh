rpm -qa |
while read X
do
	rpm -ql "$X" |
	grep "$@" &&
	echo "  found in $X"
done
