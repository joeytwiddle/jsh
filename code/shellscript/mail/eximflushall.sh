MSGIDS=`mailq | takecols 3 | grep -v '^$'`

exim -M $MSGIDS
