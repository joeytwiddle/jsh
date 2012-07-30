#!/bin/bash

lastline="thisString_willNEVERex1st"

while read line
do
	[ "$line" = "$lastline" ] || echo "$line"
	lastline="$line"
done

