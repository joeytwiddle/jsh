rpm -qa |
while read X
do
	rpm -ql "$X" |
	grep "$@" &&
	printf "%s\n\n" "  was found in $X"
done
