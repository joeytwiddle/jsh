addonetoclasspath() {
	export CLASSPATH="$CLASSPATH:$1"
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
