find . -type l |
while read X
do
	'ls' -ld "$X"
	# echo "$X" >&2
	rm "$X"
done |
sed 's| -> |	->	|' |
sed 's|.* \([^ 	]*	->	.*\)|\1|' |
sort |
cat >> .symlinks.list
