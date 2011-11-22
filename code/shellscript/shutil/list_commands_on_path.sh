echo "$PATH" | tr ':' '\n' |
while read PATHBIT
do
	find "$PATHBIT"/ -maxdepth 1 -type f -or -type l |
	while read EXE
	do [ -x "$EXE" ] && echo "$EXE"
	done
done |
afterlast /
