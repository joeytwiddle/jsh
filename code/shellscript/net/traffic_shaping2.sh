## TODO: we really need to allow trees of pipes, so we can make really nice shaping rules

clear_all_shaping () {
	/sbin/tc qdisc del dev "$INTERFACE" root
}

create_main_pipe () {
	/sbin/tc qdisc add dev "$INTERFACE" root handle 1: prio bands 9
}

create_pipe () {
	PIPENUM="$1"
	shift
	/sbin/tc qdisc add dev "$INTERFACE" parent 1:"$PIPENUM" handle 1"$PIPENUM": "$@"
}

create_throttled_pipe () {
	## Token Buffer Filter was recommended as the best sensible buffer/dropping algorithm to use.
	SPEED="$2"
	PEAKSPEED=`expr "$SPEED" '*' 5 / 4`
	create_pipe "$1" tbf rate "$SPEED"bps buffer 1600 peakrate "$PEAKSPEED"bps mtu 1518 mpu 64 latency 50ms
}

create_free_pipe () {
	create_pipe "$1" pfifo
}

filter_match () {
	/sbin/tc filter add dev "$INTERFACE" parent 1:0 prio 1 protocol ip u32 match "$@"
}

filter_destip () {
	DESTIP="$1"
	TOPIPE="$2"
	filter_match ip dst "$DESTIP"/32 flowid 1:$TOPIPE
	## For subnet use 24 not 32 (ignores last digit of IP)
}

filter_ports () {
	case "$1" in
		-from)
			PORTDIRECTION=dport
		;;
		-to)
			PORTDIRECTION=sport
		;;
		*)
			echo "filter_ports [ -from | -to ] <port_nums>... <target_pipe>"
			return 1
		;;
	esac
	shift

	PORTS=""
	while [ "$2" ]
	do
		PORTS="$PORTS""$1"" "
		shift
	done
	TOPIPE="$1"

	for PORT in $PORTS
	do filter_match ip "$PORTDIRECTION" "$PORT" 0xffff flowid 1:"$TOPIPE"
	done
}

filter_small () {
	TOPIPE="$1"
	## Captures small packets:
	filter_match u16 0x0000 0xff80 at 2 flowid 1:$TOPIPE
}

filter_rest () {
	TOPIPE="$1"
	## Captures all remaining packets:
	filter_match u8 0 0 at 0 flowid 1:$TOPIPE
}



## Needed outside runnable_config in order to stop below.
INTERFACE=eth1

runnable_config () {

	## Eventually this should become an external config file

	## First we need to create the subpipes (aka discs) which make up our outgoing connection:
	## We have to create them backwards; so runnable config will always look a bit weird!

	create_main_pipe
	create_throttled_pipe 9 30000 ## low priority traffic (latency ok)
	create_throttled_pipe 8 30000 ## general traffic
	create_throttled_pipe 7 30000 ## priority traffic (interactive)
	create_free_pipe 1            ## really really priority traffic (which can exceed all limits)

	## Now we need to classify packets and filter them into one of the pipes:

	filter_ports -from `seq 7777 7779` 7  ## game ports (UT here) are throttled but higher priority than webserver

	filter_ports -from 22 1               ## ssh sessions (including scp/rsync/ssh port forwarding) are umlimited

	# filter_destip 82.33.185.244 1         ## Hwi gets unlimited on anything not yet classified

	filter_ports -to 80 7                 ## websurfing is also priority

	filter_ports -from 80 8               ## webserver is general

	filter_rest 9                         ## any other traffic is throttled and very low priority

}



case "$1" in

	start)
		echo -n "Starting: "
		runnable_config
		echo "traffic_shaping"
	;;

	stop)
		echo -n "Stopping: "
		clear_all_shaping
		echo "traffic_shaping"
	;;

	restart)
		"$0" stop
		"$0" start
	;;

	test)
		"$0" start
		sleep 1m
		"$0" stop
	;;

	*)
		echo "Don't know \"$1\"" >&2
		exit 1
	;;

esac

