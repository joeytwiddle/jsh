DEV=eth1

## Stats can be accessed with: /sbin/tc -s qdisc ls dev eth1
## In jsh I use: jwatchchanges /sbin/tc -s qdisc ls dev eth1 "|" trimempty
## I also use: monitoriflow

## TODO:
##   - I don't know if we are affecting ingress at all.  man tc suggests that we can.
##   - It'd be good to attempt to limit ingress of irrelevant services, to leave room for important ones.
##   - Should we adapt the specified rate of the less important packages so that it makes more space when important streams are wanting more.  ATM they only get what the tbf leaves free, but I want the tbf to shrink to make space.
##   - debug stats pfifo handle 12: is showing up bytes (esp. at rule creation) but I don't know where they come from.  I do not believed it is being pointed to anywhere (at least not intentionally!).
##   - I have separated into a number of different discs/bands? for debugging of what's going where.  But probably we only need four bands total...

## OK finally realised that the disc #s are hex, so we can probably have max f of them, not 9!

function filter_port () {
	TYPE="$1"
	PORTDIR="$2"
	PORT="$3"
	DESTDISC="$4"
	if [ "$DESTDISC" = 2 ]
	then echo "!!! $1 $2 $3 $4"
	fi
	/sbin/tc filter add dev "$DEV" parent 1:0 prio $DESTDISC protocol ip u32 match ip $PORTDIR $PORT 0xffff flowid 1:$DESTDISC
}

case "$1" in

		start-simple)
			# /sbin/tc qdisc add dev "$DEV" root tbf rate 0.5mbit burst 5kb latency 70ms peakrate 1mbit minburst 1540
			## From: http://lartc.org/lartc.html#AEN691
			/sbin/tc qdisc add dev "$DEV" root tbf rate 99kbit burst 2000 latency 50ms
			## Note: if I change burst to 1000, ssh slows down dramatically, why?
		;;

		start)
			echo -n "shaping: "
			## configure "$DEV" so that there is a bandwidth cap on large packets going up the DSL line
			## and then garp advertising the true gateway's IP, so that other hosts use us rather than it

			## enable ip forwarding
			# echo 1 >/proc/sys/net/ipv4/ip_forward 

			## disable sending of icmp redirects (after all, we are deliberatly causing the hosts to use us instead of the true gateway)
			echo 0 >/proc/sys/net/ipv4/conf/all/send_redirects
			echo 0 >/proc/sys/net/ipv4/conf/"$DEV"/send_redirects

			## clear whatever is attached to "$DEV"
			## this can fail if there is nothing attached, btw, but that is fine
			/sbin/tc qdisc del dev "$DEV" root 2>/dev/null

			## add default 4-band priority qdisc to "$DEV"
			/sbin/tc qdisc add dev "$DEV" root handle 1: prio bands 9

			## add a <128kbit rate limit (matches DSL upstream bandwidth) with a very deep buffer to the bulk band (#3)
			## 99 kbit/s == 8 1500 byte packets/sec, so a latency of 5 sec means we will buffer up to 40 of these big
			## ones before dropping. a buffer of 1600 tokens means that at any time we are ready to burst one of
			## these big ones (at the peakrate, 128kbit/s). the mtu of 1518 instead of 1514 is in case I ever start
			## using vlan tagging, because if mtu is too low (like 1500) then all traffic blocks
			# # /sbin/tc qdisc add dev "$DEV" parent 1:3 handle 13: tbf rate 20kbit buffer 1600 peakrate 40kbit mtu 1518 mpu 64 latency 50ms
			# # /sbin/tc qdisc add dev "$DEV" parent 1:3 handle 13: tbf rate 80kbit buffer 1600 peakrate 100kbit mtu 1518 mpu 64 latency 50ms
			# # /sbin/tc qdisc add dev "$DEV" parent 1:3 handle 13: tbf rate 60kbit buffer 1600 peakrate 75kbit mtu 1518 mpu 64 latency 50ms
			# /sbin/tc qdisc add dev "$DEV" parent 1:9 handle 19: tbf rate 80kbit buffer 1600 peakrate 90kbit mtu 1518 mpu 64 latency 50ms
			# # /sbin/tc qdisc add dev "$DEV" parent 1:9 handle 19: tbf rate 80kbit buffer 1600 peakrate 100kbit mtu 1518 mpu 64 latency 50ms
			# # # /sbin/tc qdisc add dev "$DEV" parent 1:9 handle 19: tbf rate 80kbit buffer 1600 peakrate 120kbit mtu 1518 mpu 64 latency 50ms
			## Decided they should have equal weighting:
			# /sbin/tc qdisc add dev "$DEV" parent 1:9 handle 19: tbf rate 60kbit buffer 1600 peakrate 70kbit mtu 1518 mpu 64 latency 50ms
			# /sbin/tc qdisc add dev "$DEV" parent 1:9 handle 19: tbf rate 50kbit buffer 1600 peakrate 60kbit mtu 1518 mpu 64 latency 50ms

			# /sbin/tc qdisc add dev "$DEV" parent 1:9 handle 19: tbf rate 50kbit buffer 1600 peakrate 60kbit mtu 1518 mpu 64 latency 50ms
			/sbin/tc qdisc add dev "$DEV" parent 1:9 handle 19: tbf rate 40kbit buffer 1600 peakrate 50kbit mtu 1518 mpu 64 latency 50ms
			# /sbin/tc qdisc add dev "$DEV" parent 1:9 handle 19: tbf rate 30kbit buffer 1600 peakrate 40kbit mtu 1518 mpu 64 latency 50ms
			# /sbin/tc qdisc add dev "$DEV" parent 1:9 handle 19: tbf rate 20kbit buffer 1600 peakrate 30kbit mtu 1518 mpu 64 latency 50ms

			## For small packets:
			# /sbin/tc qdisc add dev "$DEV" parent 1:8 handle 18: tbf rate 20kbit buffer 1600 peakrate 30kbit mtu 1518 mpu 64 latency 50ms
			# # /sbin/tc qdisc add dev "$DEV" parent 1:8 handle 18: tbf rate 30kbit buffer 1600 peakrate 40kbit mtu 1518 mpu 64 latency 50ms
			# # # /sbin/tc qdisc add dev "$DEV" parent 1:8 handle 18: tbf rate 20kbit buffer 1600 peakrate 120kbit mtu 1518 mpu 64 latency 50ms
			## Decided they should have equal weighting:
			# /sbin/tc qdisc add dev "$DEV" parent 1:8 handle 18: tbf rate 40kbit buffer 1600 peakrate 50kbit mtu 1518 mpu 64 latency 50ms
			# /sbin/tc qdisc add dev "$DEV" parent 1:8 handle 18: tbf rate 50kbit buffer 1600 peakrate 60kbit mtu 1518 mpu 64 latency 50ms

			# /sbin/tc qdisc add dev "$DEV" parent 1:8 handle 18: tbf rate 50kbit buffer 1600 peakrate 60kbit mtu 1518 mpu 64 latency 50ms
			/sbin/tc qdisc add dev "$DEV" parent 1:8 handle 18: tbf rate 40kbit buffer 1600 peakrate 50kbit mtu 1518 mpu 64 latency 50ms
			# /sbin/tc qdisc add dev "$DEV" parent 1:8 handle 18: tbf rate 30kbit buffer 1600 peakrate 40kbit mtu 1518 mpu 64 latency 50ms
			# /sbin/tc qdisc add dev "$DEV" parent 1:8 handle 18: tbf rate 20kbit buffer 1600 peakrate 30kbit mtu 1518 mpu 64 latency 50ms

			## add fifos to the other bands so we can have some stats
			for SUBDISC in `seq 7 -1 1`
			do
				# if [ "$SUBDISC" = 6 ]
				# then
					# /sbin/tc qdisc add dev "$DEV" parent 1:$SUBDISC handle 1$SUBDISC: tbf rate 240kbit buffer 1600 peakrate 280kbit mtu 1518 mpu 64 latency 50ms
				# else
					/sbin/tc qdisc add dev "$DEV" parent 1:$SUBDISC handle 1$SUBDISC: pfifo
				# fi
			done

			## add a filter so DIP's within the house go to prio band #1 instead of being assigned by TOS
			## thus traffic going to an inhouse location has top priority
			# /sbin/tc filter add dev "$DEV" parent 1:0 prio 1 protocol ip u32 match ip dst 192.168.168.0/24 flowid 1:1
			/sbin/tc filter add dev "$DEV" parent 1:0 prio 1 protocol ip u32 match ip dst 10.0.0.0/24 flowid 1:1

			## multicasts also go into band #1, since they are all inhouse (and we don't want to delay ntp packets and mess up time)
			/sbin/tc filter add dev "$DEV" parent 1:0 prio 1 protocol ip u32 match ip dst 224.0.0.0/4 flowid 1:1

			### Critical:

			## Games:
			##          unreal....most................
			for PORT in 7775 7776 7777 7778 7779 27900
			do
				filter_port batch$PORT sport $PORT 1
				filter_port batch$PORT dport $PORT 1
			done

			## Hwi's mail services:
			filter_port smtp     sport 25   3
			filter_port ssmtp    sport 465  3
			filter_port imap2    sport 143  3
			filter_port imap3    sport 220  3
			filter_port imaps    sport 993  3
			filter_port pop2     sport 109  3
			filter_port pop3     sport 110  3
			filter_port pop3s    sport 995  3
			## Remote mail:
			filter_port smtp     dport 25   3
			filter_port ssmtp    dport 465  3
			filter_port imap2    dport 143  3
			filter_port imap3    dport 220  3
			filter_port imaps    dport 993  3
			filter_port pop2     dport 109  3
			filter_port pop3     dport 110  3
			filter_port pop3s    dport 995  3

			## Peercast:
			filter_port peercast dport 7144 4
			filter_port peercast sport 7144 4
			filter_port peercast dport 7145 4
			filter_port peercast sport 7145 4
			## Dialect:
			filter_port peercast dport 7900 4
			filter_port peercast sport 7900 4
			## Dialect's remote port:
			filter_port peercast dport 7100 4
			filter_port peercast sport 7100 4

			### Interactive:

			## apparently, one "could tell ssh from scp; scp sets the IP diffserv flags to indicate bulk traffic"
			## but i don't know how to do this.  And what about rsync?
			filter_port ssh      sport 22   4
			filter_port ssh      dport 22   4

			## Vnc-http, Vnc, and X
			for VNCPORT in `seq 5800 5899` `seq 5900 5999` `seq 6000 6010`
			do
				filter_port vnc dport $VNCPORT 4
				filter_port vnc sport $VNCPORT 4
			done

			## Realplay
			filter_port realplay dport 554 5
			filter_port realplay sport 554 5

			## Fast websurfing:
			filter_port http   dport 80   5
			filter_port https  dport 443  5
			## Lower priority webserver:
			filter_port http   sport 80   6
			filter_port https  sport 443  6

			## DNS:
			filter_port domain dport 53   6
			filter_port domain sport 53   6

			## CVS:
			filter_port cvs    dport 2401 7
			filter_port cvs    sport 2401 7

			## And all the smeggin rest:
			## I gave up on socks line 217 of /etc/services, resume there?  I don't really know which ones are needed.  rsync might be preferably batched.  irc probably needs higher priority, unless it's being used for d/l'ing!
			##          ftp telnet gopher finger hostnames rtelnet sftp nntp ntp! snmp irc ldap snpp talk ntalk rsync ftps ftps-data telnets ircs socks
			for PORT in 21  23     70     79     101       107     115  119  123  161  194 389  444  517  518   873   990  989       992     994  1080
			do
				filter_port batch$PORT sport $PORT 7
				filter_port batch$PORT dport $PORT 7
			done

			## small IP packets go to band #2 (Joey: #3)
			## by small I mean <128 bytes in the IP datagram, or in other words, the upper 9 bits of the iph.tot_len are 0
			## note: this completely fails to do the right thing with fragmented packets. However
			## we happen to not have many (any? icmp maybe, but tcp?) fragmented packets going out the DSL line
			# /sbin/tc filter add dev "$DEV" parent 1:0 prio 2 protocol ip u32 match u16 0x0000 0xff80 at 2 flowid 1:2
			## Joey finds there are too many, at least when running multiple bittorrents.  CONSIDER: make abother tbf for the small packets?
			/sbin/tc filter add dev "$DEV" parent 1:0 prio 8 protocol ip u32 match u16 0x0000 0xff80 at 2 flowid 1:8

			## a final catch-all filter that redirects all remaining ip packets to band #4
			## presumably all that is left are large packets headed out the DSL line, which are
			## precisly those we wish to rate limit in order to keep them from filling the
			## DSL modem's uplink egress queue and keeping the shorter 'interactive' packets from
			## getting through
			## the dummy match is required to make the command parse
			/sbin/tc filter add dev "$DEV" parent 1:0 prio 9 protocol ip u32 match u8 0 0 at 0 flowid 1:9

			## have the rest of the house think we are the gateway
			## the reason I use arpspoofing is that I want automatic failover to the real gateway
			## should this machine go offline, and since the real gateway does not do vrrp, I hack
			## the network and steal its arp address instead
			## It takes 5-10 seconds for the failback to happen, but it works :-)
			# /usr/sbin/arpspoof -i "$DEV" 192.168.168.1 >/dev/null 2>&1 &
			# echo $! >/var/run/shapedsl.arpspoof.pid
			echo "startified"
		;;

		stop)
			/sbin/tc qdisc del dev "$DEV" root # 2>/dev/null
			# if [ -r /var/run/shapedsl.arpspoof.pid ]
			# then
				# kill `cat /var/run/shapedsl.arpspoof.pid`
				# rm /var/run/shapedsl.arpspoof.pid
			# fi
		;;

		restart)
			$0 stop
			$0 start
		;;

		*)
			echo "Usage: $0 [start|stop|restart]"
			exit 1
		;;

esac

exit 0

