DEV=eth1

export COUNT=0
export DEBUG_MODE=true

function filter_port () {
	if [ "$DEBUG_MODE" ]
	then
		if [ "$COUNT" -lt 6 ]
		then
			COUNT=`expr "$COUNT" + 1`
			/sbin/tc qdisc add dev "$DEV" parent 1:$COUNT handle 1$COUNT: pfifo
		fi
		DEST="$COUNT"
	else DEST="$4"
	fi
	/sbin/tc filter add dev "$DEV" parent 1:0 prio $DEST protocol ip u32 match ip $2 $3 0xffff flowid 1:$DEST
}

case "$1" in

		start-simple)
			# /sbin/tc qdisc add dev "$DEV" root tbf rate 0.5mbit burst 5kb latency 70ms peakrate 1mbit minburst 1540
			## From: http://lartc.org/lartc.html#AEN691
			/sbin/tc qdisc add dev "$DEV" root tbf rate 99kbit burst 2000 latency 50ms
			## Note: if I change burst to 1000, ssh slows down dramatically, why?
		;;

		start)
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
			# /sbin/tc qdisc add dev "$DEV" parent 1:3 handle 13: tbf rate 20kbit buffer 1600 peakrate 40kbit mtu 1518 mpu 64 latency 50ms
			# /sbin/tc qdisc add dev "$DEV" parent 1:3 handle 13: tbf rate 80kbit buffer 1600 peakrate 100kbit mtu 1518 mpu 64 latency 50ms
			# /sbin/tc qdisc add dev "$DEV" parent 1:3 handle 13: tbf rate 60kbit buffer 1600 peakrate 75kbit mtu 1518 mpu 64 latency 50ms
			/sbin/tc qdisc add dev "$DEV" parent 1:9 handle 19: tbf rate 80kbit buffer 1600 peakrate 100kbit mtu 1518 mpu 64 latency 50ms

			## For small packets:
			/sbin/tc qdisc add dev "$DEV" parent 1:8 handle 18: tbf rate 20kbit buffer 1600 peakrate 40kbit mtu 1518 mpu 64 latency 50ms

			## add fifos to the other two bands so we can have some stats
			# /sbin/tc qdisc add dev "$DEV" parent 1:2 handle 12: pfifo
			# /sbin/tc qdisc add dev "$DEV" parent 1:1 handle 11: pfifo
			## Joey sez: anyone know where we can access these stats/fifos?!
			## Joey answers: tc -s qdisc ls dev eth1

			## add a filter so DIP's within the house go to prio band #1 instead of being assigned by TOS
			## thus traffic going to an inhouse location has top priority
			# /sbin/tc filter add dev "$DEV" parent 1:0 prio 1 protocol ip u32 match ip dst 192.168.168.0/24 flowid 1:1
			/sbin/tc filter add dev "$DEV" parent 1:0 prio 1 protocol ip u32 match ip dst 10.0.0.0/24 flowid 1:1

			## multicasts also go into band #1, since they are all inhouse (and we don't want to delay ntp packets and mess up time)
			/sbin/tc filter add dev "$DEV" parent 1:0 prio 1 protocol ip u32 match ip dst 224.0.0.0/4 flowid 1:1

			### Critical:

			## Hwi's mail services:
			filter_port imap sport 143 1
			filter_port imap3 sport 220 1
			filter_port imaps sport 993 1
			## Remote mail:
			filter_port imap dport 143 1
			filter_port imap3 dport 220 1
			filter_port imaps dport 993 1

			## Peercast:
			filter_port peercast dport 7144 1
			filter_port peercast sport 7144 1

			### Interactive:

			## apparently, one "could tell ssh from scp; scp sets the IP diffserv flags to indicate bulk traffic"
			## but i don't know how to do this.  And what about rsync?
			filter_port ssh sport 22 1
			filter_port ssh dport 22 1

			## Fast websurfing:
			filter_port http dport 80 1
			## Lower priority webserver:
			filter_port http sport 80 2

			## CVS:
			filter_port cvs dport 2401 2
			filter_port cvs sport 2401 2

			## small IP packets go to band #2 (Joey: #3)
			## by small I mean <128 bytes in the IP datagram, or in other words, the upper 9 bits of the iph.tot_len are 0
			## note: this completely fails to do the right thing with fragmented packets. However
			## we happen to not have many (any? icmp maybe, but tcp?) fragmented packets going out the DSL line
			# /sbin/tc filter add dev "$DEV" parent 1:0 prio 2 protocol ip u32 match u16 0x0000 0xff80 at 2 flowid 1:2
			## Joey finds there are too many, at least when running multiple bittorrents.  CONSIDER: make abother tbf for the small packets?
			/sbin/tc filter add dev "$DEV" parent 1:0 prio 8 protocol ip u32 match u16 0x0000 0xff80 at 2 flowid 1:9

			## a final catch-all filter that redirects all remaining ip packets to band #4
			## presumably all that is left are large packets headed out the DSL line, which are
			## precisly those we wish to rate limit in order to keep them from filling the
			## DSL modem's uplink egress queue and keeping the shorter 'interactive' packets from
			## getting through
			## the dummy match is required to make the command parse
			/sbin/tc filter add dev "$DEV" parent 1:0 prio 9 protocol ip u32 match u8 0 0 at 0 flowid 1:10

			## have the rest of the house think we are the gateway
			## the reason I use arpspoofing is that I want automatic failover to the real gateway
			## should this machine go offline, and since the real gateway does not do vrrp, I hack
			## the network and steal its arp address instead
			## It takes 5-10 seconds for the failback to happen, but it works :-)
			# /usr/sbin/arpspoof -i "$DEV" 192.168.168.1 >/dev/null 2>&1 &
			# echo $! >/var/run/shapedsl.arpspoof.pid
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

