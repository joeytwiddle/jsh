CURRENT=`runlevel | after ' '`
DESIRED="$1"
diffcoms "ls /etc/rc$CURRENT.d" "ls /etc/rc$DESIRED.d" |
drop 6 |
after S.. |
while read X
do
	/etc/init.d/"$X" start
	echo
done
