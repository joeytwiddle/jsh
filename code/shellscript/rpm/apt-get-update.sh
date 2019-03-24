#!/bin/sh

FILE=/etc/apt/all-sources.list

if [ ! -f "$FILE" ] || [ "$1" = --help ]
then
	echo
	echo "apt-get-update is intended to update a larger set of packages than your default install sources, from $FILE"
	echo
	echo "  It won't do anything unless that file exists!"
	echo
	echo "  By using it I can quickly change the selection of source repositories (subset) I want to use (in /etc/apt/sources.list) without having to re-get the listings."
	echo
	echo
	echo "  As an alternative you could consider adding --no-list-cleanup to apt's config."
	echo
	exit 1
fi

# apt-get --config-file /root/apt-get-update-all-config.cfg update
apt-get --option Dir::Etc::sourcelist=$FILE update

## In case someone runs apt-get update, you can retrieve all your sources from this backup.
# tar c /var/lib/apt/lists | gzip -1 > /tmp/var_lib_apt_lists.tgz
## (Disabled until I clear more HD space!)
