#!/bin/sh
## A stream piped in a loop:
(echo 0; sleep 1; tail -f /tmp/looped.stream) |
while read N; do
	echo `expr $N + 1`
	echo $N >&2
done > /tmp/looped.stream

# rm -f /tmp/tmpfifo
# mkfifo /tmp/tmpfifo
# echo A
# echo 0 >> /tmp/tmpfifo &
# echo B
# tail -f /tmp/tmpfifo |
# while read N; do
	# echo "$N"
	# echo `expr "$N" + 1` >> /tmp/tmpfifo &
# done
