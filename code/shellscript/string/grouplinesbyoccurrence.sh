TMPFILE=`jgettmp "$1"`

cat > $TMPFILE

cat $TMPFILE |

removeduplicatelines |

while read LINE
do

	grep -c "^$LINE$" $TMPFILE | tr -d '\n'

	echo "	$LINE"

done

jdel $TMPFILE
