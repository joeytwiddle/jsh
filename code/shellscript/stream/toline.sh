## TODO: Rename grepto
## Hides all lines after first occurrence of grep pattern (regexp) is met.
## TODO: -x exclusive option

PAT="$1"

while read LINE
do
	echo "$LINE" | grep "$PAT" && break
	echo "$LINE"
done

cat > /dev/null
