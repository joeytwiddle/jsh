addonetoclasspath() {
	export CLASSPATH="$CLASSPATH:$1"
	if test "$JIKESPATH"
	then export JIKESPATH="$JIKESPATH:$1"
	fi
}

if test "$*" = ""; then
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
