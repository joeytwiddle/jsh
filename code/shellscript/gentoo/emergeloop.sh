LOGNUM=0

while true
do

	(

		nice -n 20 emerge $EXTRAARGS "$@" 2>&1

		if [ "$?" = 0 ]
		then
			echo
			echo ">>>>>> Successful exit code.  Stopping."
			echo
			break
		fi

		echo
		echo ">>>>>> Failure!  Resuming after 10 seconds..."
		echo
		sleep 10

	) | tee /tmp/emerge-$LOGNUM.log

	EXTRAARGS="--resume --skipfirst"
	LOGNUM=` expr "$LOGNUM" + 1 `

done
