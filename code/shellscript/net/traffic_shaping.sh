
case "$1" in

		start)
			## configure eth1 so that there is a bandwidth cap on large packets going up the DSL line
			## and then garp advertising the true gateway's IP, so that other hosts use us rather than it

			## enable ip forwarding
			# echo 1 >/proc/sys/net/ipv4/ip_forward 

			## disable sending of icmp redirects (after all, we are deliberatly causing the hosts to use us instead of the true gateway)
			echo 0 >/proc/sys/net/ipv4/conf/all/send_redirects
			echo 0 >/proc/sys/net/ipv4/conf/eth1/send_redirects

			## clear whatever is attached to eth1
			## this can fail if there is nothing attached, btw, but that is fine
			/sbin/tc qdisc del dev eth1 root 2>/dev/null

			## add default 3-band priority qdisc to eth1
			/sbin/tc qdisc add dev eth1 root handle 1: prio

			## add a <128kbit rate limit (matches DSL upstream bandwidth) with a very deep buffer to the bulk band (#3)
			## 99 kbit/s == 8 1500 byte packets/sec, so a latency of 5 sec means we will buffer up to 40 of these big
			## ones before dropping. a buffer of 1600 tokens means that at any time we are ready to burst one of
			## these big ones (at the peakrate, 128kbit/s). the mtu of 1518 instead of 1514 is in case I ever start
			## using vlan tagging, because if mtu is too low (like 1500) then all traffic blocks
			/sbin/tc qdisc add dev eth1 parent 1:3 handle 13: tbf rate 99kbit buffer 1600 peakrate 120kbit mtu 1518 mpu 64 latency 5000ms

			## add fifos to the other two bands so we can have some stats
			/sbin/tc qdisc add dev eth1 parent 1:1 handle 11: pfifo
			/sbin/tc qdisc add dev eth1 parent 1:2 handle 12: pfifo

			## add a filter so DIP's within the house go to prio band #1 instead of being assigned by TOS
			## thus traffic going to an inhouse location has top priority
			# /sbin/tc filter add dev eth1 parent 1:0 prio 1 protocol ip u32 match ip dst 192.168.168.0/24 flowid 1:1

			## multicasts also go into band #1, since they are all inhouse (and we don't want to delay ntp packets and mess up time)
			/sbin/tc filter add dev eth1 parent 1:0 prio 1 protocol ip u32 match ip dst 224.0.0.0/4 flowid 1:1

			## ssh packets to the outside go to band #2 (this is harsh, but I can't tell scp from ssh so I can't filter them better)
			## (actually I could tell ssh from scp; scp sets the IP diffserv flags to indicate bulk traffic)
			## Joey moved ssh to band 1 =)
			# /sbin/tc filter add dev eth1 parent 1:0 prio 2 protocol ip u32 match ip sport 22 0xffff flowid 1:2
			/sbin/tc filter add dev eth1 parent 1:0 prio 1 protocol ip u32 match ip sport 22 0xffff flowid 1:2

			## small IP packets go to band #2
			## by small I mean <128 bytes in the IP datagram, or in other words, the upper 9 bits of the iph.tot_len are 0
			## note: this completely fails to do the right thing with fragmented packets. However
			## we happen to not have many (any? icmp maybe, but tcp?) fragmented packets going out the DSL line
			/sbin/tc filter add dev eth1 parent 1:0 prio 2 protocol ip u32 match u16 0x0000 0xff80 at 2 flowid 1:2

			## a final catch-all filter that redirects all remaining ip packets to band #3
			## presumably all that is left are large packets headed out the DSL line, which are
			## precisly those we wish to rate limit in order to keep them from filling the
			## DSL modem's uplink egress queue and keeping the shorter 'interactive' packets from
			## getting through
			## the dummy match is required to make the command parse
			/sbin/tc filter add dev eth1 parent 1:0 prio 3 protocol ip u32 match u8 0 0 at 0 flowid 1:3

			## have the rest of the house think we are the gateway
			## the reason I use arpspoofing is that I want automatic failover to the real gateway
			## should this machine go offline, and since the real gateway does not do vrrp, I hack
			## the network and steal its arp address instead
			## It takes 5-10 seconds for the failback to happen, but it works :-)
			# /usr/sbin/arpspoof -i eth1 192.168.168.1 >/dev/null 2>&1 &
			# echo $! >/var/run/shapedsl.arpspoof.pid
		;;

		stop)
			/sbin/tc qdisc del dev eth1 root # 2>/dev/null
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

