
TMPDIR=/tmp/testports.tmp
rm -rf $TMPDIR
mkdir -p $TMPDIR

TARGET="$1"

nmap "$TARGET" |
grep " open " |
sed "s+\(.*\)/tcp[ ]*open[ ]*\(.*\)+\1 \2+" |
while read PORT SERVICE
do
	( echo "HELO" && cat ) |
	telnet "$TARGET" "$PORT" |
	(
		grep -v "^Trying .*\.\.\.$" |
		grep -v "^Connected to .*\.$" |
		grep -v "^Escape character is '\^]'.$"
	) > $TMPDIR/$TARGET-$PORT-$SERVICE &
done

sleep 15
killall telnet

more $TMPDIR/* | cat
