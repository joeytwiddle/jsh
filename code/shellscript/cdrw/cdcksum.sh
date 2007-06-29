## ls preferable to find because former gives physical order, latter alphabetical
'ls' -R | ls-Rtofilelist |
# find . -type f |
sedreplace "^\./" "" |
while read FILE
do
	qkcksum "$FILE"
done
