LOGNUM=0

while true
do

	if nice -n 20 emerge $EXTRAARGS "$@" 2>&1 # Can't fit this in without breaking the exit: | tee /tmp/emerge-$LOGNUM.log
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

	sleep 10
	EXTRAARGS="--resume --skipfirst"
	LOGNUM=` expr "$LOGNUM" + 1 `

done
