## jsh-help: Like emerge, but skips failed packages and compiles all it can.
## jsh-help: Runs emerge as normal, but if there is a failure, restarts the emerge with --resume --skipfirst .

LOGNUM=0

while true
do

	if emerge $EXTRAARGS "$@" 2>&1
	then
		echo
		echo ">>>>>> [emergeloop] Successful exit code.  Stopping."
		echo
		break
	else
		echo
		echo ">>>>>> [emergeloop] Failure!  Resuming after 10 seconds..."
		echo
	fi

	## If we put it in the if, it doesn't return the exit code
	## If we put it outside, like this, then exit/break doesn't work.
	# |
	# tee /tmp/emerge-$LOGNUM.log

	sleep 10
	EXTRAARGS="--resume --skipfirst"
	LOGNUM=` expr "$LOGNUM" + 1 `

done
