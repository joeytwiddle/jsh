[ "$1" ] && export DISPLAY="$1"
for X in `seq 1 10`
do
	xsnapshot
	sleep 10
done
