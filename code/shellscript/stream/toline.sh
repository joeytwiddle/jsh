PAT="$1"

while read LINE
do
	echo "$LINE" | grep "$PAT" && break
	echo "$LINE"
done

cat > /dev/null
