## Note: If you want to pipe FROM both stdout and stderr streams of previous call, you should do:
# ... command ... 2>&1 | pipeboth ... | ...
## ie. outputs on both streams, but | only inputs the previous stdout, not stderr

cat |

while read X
do
	echo "$X"
	echo "$X" >&2
done
