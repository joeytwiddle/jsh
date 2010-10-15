#!/bin/sh
wall << !
Killing pppd
!

ppp-off
killall pppd
sleep 60

wall << !
Making a phone call
!

pppd call tmpphonecall &
sleep 30
killall pppd

wall << !
Phone call over.  Restoring pppd...
!

ppp-on
sleep 2
ensure-ip-state | wall
