REBEFORE="$1"
RETODO="$2"
REAFTER="$3"
shift
shift
shift

cat "$@" |
sed "s+\($REBEFORE\)\($RETODO\)\($REAFTER\)+\1+" > /tmp/left.out

cat "$@" |
sed "s+\($REBEFORE\)\($RETODO\)\($REAFTER\)+\2+" > /tmp/todo.out

cat "$@" |
sed "s+\($REBEFORE\)\($RETODO\)\($REAFTER\)+\3+" > /tmp/right.out
