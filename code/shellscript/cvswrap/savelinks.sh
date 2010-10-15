#!/bin/sh
find . -type l | while read X; do
	Y=`justlinks "$X"`
	echo "ln -s \"$Y\" \"$X\""
done
