#!/bin/sh

process_name="$1"
shift

if ! pgrep "$process_name"
then
	echo "Could not find specified process '$process_name' to begin with!"
	exit 3
fi

while pgrep "$process_name" >/dev/null
do sleep 4
done

"$@"
