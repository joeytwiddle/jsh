FILE=/etc/apt/all-sources.list

if [ ! -f "$FILE" || "$1" = --help ]
then
	echo "apt-get-update is intended to update a larger set of packages than your default install sources, from $FILE"
	echo "  It won't do anything unless that file exists!"
	exit 1
fi

# apt-get --config-file /root/apt-get-update-all-config.cfg update
apt-get --option Dir::Etc::sourcelist=$FILE update

## In case someone runs apt-get update, you can retrieve all your sources from this backup.
tar c /var/lib/apt/lists | gzip -1 > /tmp/var_lib_apt_lists.tgz
