addonetoclasspath() {
	export CLASSPATH="$CLASSPATH:$1"
	if test "$JIKESPATH"
	then export JIKESPATH="$JIKESPATH:$1"
	fi
}

## TODO: Consider adding to beginning of classpath (although arguments remain in same order)
## This make the script more powerful on its own.

if test "$*" = ""
then
	echo "Adds each argument to the end of your classpath."
	exit 1
fi

if test "$1" = -
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
