jwatchchanges -fine "cat /proc/partitions | columnise"

exit



## This old method is useless

SLEEPFOR=1

TARGET=target0
PARTITION=disc
# PARTITION=part3

if [ "$1" ] && [ "$2" ]
then
	TARGET="$1"
	PARTITION="$2"
fi

while true
do

	cat /proc/partitions |
	grep $TARGET | grep $PARTITION

	if [ $SLEEPFOR -lt 8 ]
	then SLEEPFOR=`expr $SLEEPFOR '*' 2`
	fi
	sleep $SLEEPFOR

done |

	(

		FIRSTRUN=true

		while true
		do

			read MAJOR MINOR BLOCKS NAME RIO RMERGE RSECT RUSE WIO WMERGE WSECT WUSE RUNNING USE AVEQ
			# echo MAJOR MINOR BLOCKS NAME RIO RMERGE RSECT RUSE WIO WMERGE WSECT WUSE RUNNING USE AVEQ
			# echo $MAJOR $MINOR $BLOCKS $NAME $RIO $RMERGE $RSECT $RUSE $WIO $WMERGE $WSECT $WUSE $RUNNING $USE $AVEQ

			# NEWVAL="$USE"
			NEWVAL=`expr "$RIO" + "$WIO"`
			# echo -n -e "$RIO in\t$WIO out\t"
			# echo "newval = $NEWVAL"
			NEWTIME=`date +"%s.%N" | sed 's+\(.*\....\).*+\1+'`

			if [ $FIRSTRUN ]
			then FIRSTRUN=
			else

				DVAL=`expr $NEWVAL - $OLDVAL`
				DTIME=`echo "scale=0; $NEWTIME - $OLDTIME" | bc`

				# BPS=`expr $DVAL / $DTIME`

				KPS=`echo "scale=3; $DVAL"0.0" / $DTIME" | bc`

				echo "$KPS kbps"

			fi

			OLDVAL="$NEWVAL"
			OLDTIME="$NEWTIME"

		done

	)

