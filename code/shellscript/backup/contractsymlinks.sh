find . -type l |
while read X
do
	'ls' -ld "$X"
	rm "$X"
done |
sed 's| -> |	->	|' |
sed 's|.* \([^ 	]*	->	.*\)|\1|' |
cat >> .symlinks.list
