LIST=""
while read X; do
	LIST="$X
$LIST"
done
printf "$LIST"
