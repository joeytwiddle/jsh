if test "x$1" = "" -o "x$2" = ""; then
  echo "Please invoke with killchild \$\$ <name (and args)>"
  exit 1
fi

MYID=$$
# PID=$1
echo "PPID = $PPID =? given = $PID !=? mine = $MYID"
ARGS=`echo $* | sed "s/^$1 //"`
echo "Looking for $ARGS with PPID=$PID"
LINE=`psforkillchild |
  grep "$ARGS" |
  grep -v "$MYID .*killchild $*" |
  grep -v "$MYID .*grep" |
  head -n 1`

psforkillchild |
  grep "$PID .* $ARGS" |
  grep -v "$MYID .*killchild $*" |
  grep -v "$MYID .*grep"

# PARENTID=`echo $LINE | takecols 1`
CHILDID=`echo $LINE | takecols 2`

#if test "x$PID" = "x$CHILDID"; then
#	echo "Found myself!"
#	exit 1
#else
#	if test "x$PARENTID" = "x$PID"; then
		echo "Killing $CHILDID"
		kill -KILL $CHILDID
#	else
#		echo "Did not work"
#		exit 1
#	fi
#fi
