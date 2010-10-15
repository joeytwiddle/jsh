#!/bin/sh
## Actually implemented to append an email to a mailbox file
## Can be changed if joey's /etc/alises is updated accordingly.
while test -f "$*.lock"; do
	sleep 1
done
touch "$*.lock"
echo "$USER $?" >> /tmp/catintofile.log
chmod a+w /tmp/catintofile.log
tee -a "$*".bak |
cat >> "$*"
rm -f "$*.lock"
