#!/bin/sh

# There is geoiplookup in the geoip-bin package, but its static database is out of date.  (I tried it on two DigitalOcean servers, and it was wrong in both cases.)

ip="$1"

# This returns a whole JSON record, more than we actually need.
curl ipinfo.io/"$ip"
