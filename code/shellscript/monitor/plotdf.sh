halfway() {
cat $JPATH/logs/df.log |
grep -v "^Filesystem" |
takecols 1 3 2 |
tr "\n" " " |
sed "s+TIME=+\\
+g"
}

PLOTFILE=`jgettmp df.data`
PLOTFILE=/tmp/plotdf.data

halfway |
sed "s+/[^ ]* ++g" > "$PLOTFILE"

FSES=`
halfway |
tail -n 1 |
sed "s+[^/]*\(/[^ ]*\) [^/]*+\1 +g"
`

PLOTLINE="plot [] [0:] "
N=2
for FS in $FSES
do
	# If a FS device name was passed as argument, avoid it!
	# if ! contains "$*" "$FS"; then
	# If a FS device name was passed as argument, show it!
	# if contains "$*" "$FS"; then
	if contains "$FS" "$*"; then
		M=`expr $N + 1`
		PLOTLINE="$PLOTLINE '$PLOTFILE' using 1:$N t '$FS' w l $N, '$PLOTFILE' using 1:$M t '$FS limit' w l $N,"
	fi
	N=`expr $N + 2`
done
PLOTLINE=`echo "$PLOTLINE" | sed "s+,$++"`

echo ">> $PLOTLINE"

(
# set term post color
echo "
set output 'dfplot.ps'
$PLOTLINE
"
# read KEY
cat
) |

gnuplot

# jdeltmp "$PLOTFILE"

# gv dfplot.ps
