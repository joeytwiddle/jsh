#!/bin/sh
## TODO: cable modem was not giving me a dhcp so I wasn't online but I had eth1 so this script thought I was.  :-/
# eth1      Link encap:Ethernet  HWaddr 00:11:1A:D4:18:A5  
          # UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          # RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          # TX packets:1 errors:0 dropped:0 overruns:0 carrier:0
          # collisions:0 txqueuelen:1000 
          # RX bytes:0 (0.0 b)  TX bytes:342 (342.0 b)
## The lack of IP addresses might be an indicator of a problem here!

for INTERFACE in eth0 eth1 eth2 eth3 ppp0
do
	if /sbin/ifconfig "$INTERFACE" >/dev/null 2>&1
	then
		echo "$INTERFACE"
		exit 0
	fi
done
exit 1

