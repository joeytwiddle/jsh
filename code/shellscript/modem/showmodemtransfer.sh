jwatch ls -l $JPATH/logs/packetdata.ppp # | awk ' { newsofar = $5; print (newsofar-sofar); sofar=newsofar; } '
