#!/bin/sh
find $HOME/nsmail -type d -name "*.sbd" -follow |
	grep -v ".directory" |
	while read X; do
		Y=`echo "$X" | sed "s-\(.*\)/\(.*\)\.sbd-\1/\.\2\.directory-"`;
		if test -d "$Y"; then
			echo "already exists: $Y"
		else
			echo "$Y -> "`filename "$X"`
			ln -s "$X" "$Y"
		fi
	done
ln -sf $HOME/nsmail $HOME/Mail/.nsmail.directory
