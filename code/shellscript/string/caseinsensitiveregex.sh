## Does not handle numbers well, probably filters out all except alpha
echo "$@" | sed '
	y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/
	s/[a-z]/[&]/g
	/^$/!s/$/AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz/
	:a
	s/\[\([a-z]\)\]\(.*\)\(.\)\1/[\3\1]\2\3\1/
	ta
	s/\(.*\]\).*/\1/
	y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/
	s/[a-z]/[&]/g
	/^$/!s/$/AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz/
	:a
	s/\[\([a-z]\)\]\(.*\)\(.\)\1/[\3\1]\2\3\1/
	ta
	s/\(.*\]\).*/\1/
'
