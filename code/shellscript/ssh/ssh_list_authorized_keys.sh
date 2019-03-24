#!/bin/sh

# Displays the fingerprints for authorized keys, by passing each one through ssh-keygen separately.
# These fingerprints are recorded by sshd in /var/log/auth.log
# So this script can help to match used keys against stored authorized keys.

tmpfile="$(mktemp)"

keys_file="$1"
[ -z "$keys_file" ] && keys_file="$HOME/.ssh/authorized_keys"

exec < "$keys_file"
while read KEY
do
	echo "$KEY" > "$tmpfile"
	ssh-keygen -lf "$tmpfile"
done

rm -f "$tmpfile"
