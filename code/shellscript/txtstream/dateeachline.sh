## jsh-help: Prepends each line of output with the date/time it was printed, like a logfile.
## jsh-help: Use -fine to display time in seconds+nanoseconds.

FORMAT="%d/%m/%Y %H:%M:%S"
if [ "$1" = -fine ]
then
	FORMAT="%s.%N"
	# FORMAT="$FORMAT.%N"
	shift
fi

while read LINE
do
	TIME=`date +"$FORMAT"`
	echo "[$TIME] $LINE"
done
