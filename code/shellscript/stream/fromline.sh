## TODO: Rename grepfrom
## Hides all lines until first occurrence of grep pattern (regexp) is met.
## TODO: -x exclusive option

PAT="$1"

while read LINE
do echo "$LINE" | grep "$PAT" && break
done

cat
