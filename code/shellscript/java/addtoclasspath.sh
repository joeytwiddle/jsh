addonetoclasspath() {
	TOADD="$1"
	## Provided not already in the classpath,
	if ! echo "$CLASSPATH" | tr ':' '\n' | grep "^$TOADD/*$" > /dev/null
	then ## add it:
		if [ -f "$TOADD" ] || [ -d "$TOADD" ]
		then
			export CLASSPATH="$CLASSPATH:$TOADD"
			# if test "$JIKESPATH"
			# then export JIKESPATH="$JIKESPATH:$TOADD"
			export JIKESPATH="$JIKESPATH:$TOADD"
			# fi
		else
			[ "$QUIET" ] || error "addtoclasspath: not a file or a directory: $TOADD"
		fi
	fi
}

## TODO: Consider option to add to beginning of classpath (note we'd really want arguments to remain in same order!)
## This would make the script more powerful on its own.

if [ "$*" = "" ] || [ "$1" = -help ]
then
	echo ". addtoclasspath [-quiet] <dir_or_jar>s"
	echo "<stream_of_dirs_and_jars> | . addtoclasspath [-quiet] -"
	echo "Adds each argument or line to the end of your classpath."
	echo "Option -quiet: do not complain if classpath not found."
	exit 1
fi

if [ "$1" = -quiet ]
then QUIET=true; shift
fi

if [ "$1" = - ]
then
	while read X
	do
		addonetoclasspath "$X"
	done
else
	for X
	do
		addonetoclasspath $X
	done
fi
