# Sometimes processes start with PPID 1, hence this is irrelevant.

if test "$1" = "" -o "$2" = ""; then
  echo "Syntax: killchild \$\$ \"<name (and args)>\""
  exit 1
fi

MYID=$$
PID=$1
# echo "PPID = $PPID =? given = $PID !=? mine = $MYID"
ARGS=`echo -n $* | sed "s/^$1 //"`
# echo "Looking for $ARGS with PPID=$PID"
LINE=`psforkillchild |
  grep "$PID " |
  grep "$ARGS" |
  grep -v "$MYID .*killchild $*" |
  grep -v "$MYID .*grep" |
  head -n 1`

# psforkillchild |
  # grep "$PID " |
  # grep "$ARGS" |
  # grep -v "$MYID .*killchild $*" |
  # grep -v "$MYID .*grep"

# PARENTID=`echo $LINE | takecols 1`
CHILDID=`echo $LINE | takecols 2`

#if test "x$PID" = "x$CHILDID"; then
# echo "Found myself!"
# exit 1
#else
# if test "x$PARENTID" = "x$PID"; then
    # echo "Killing $CHILDID"
    kill -KILL $CHILDID >/dev/null 2>&1
# else
#   echo "Did not work"
#   exit 1
# fi
#fi
