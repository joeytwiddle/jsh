## Big bug: telnet doesn't work properly (gets "connection lost") except when run from interactive sh
## Why/how?

TMPDIR=/tmp/testports.tmp
rm -rf $TMPDIR
mkdir -p $TMPDIR

TARGET="$1"
shift

if test "$*" = ""
then

nmap "$TARGET" |
grep " open " |
sed "s+\(.*\)/tcp[ ]*open[ ]*\(.*\)+\1 \2+"

else

	for X
	do echo "$X _"
	done

fi |

while read PORT SERVICE

do

	echo "Testing $PORT ($SERVICE)"
	
	( echo "HELO" && cat ) | telnet localhost 143 | tee y

	continue

	(
	( echo "HELO" && cat ) |
	telnet "$TARGET" "$PORT" |
	(
		cat
		# sed 's+^Trying .*\.\.\.$++
		     # s+^Connected to .*\.$++
		     # s+^Escape character is '"'"'\^]'"'"'.$++' |
		# tr -s "\n"
	) > $TMPDIR/$TARGET-$PORT-$SERVICE
	) &

done

echo "Waiting 5 seconds for results..."
sleep 5
killall telnet

more $TMPDIR/* | cat
