# apt-get --config-file /root/apt-get-update-all-config.cfg update
apt-get --option Dir::Etc::sourcelist=/etc/apt/all-sources.list update
## In case someone runs apt-get update, you can retrieve all your sources from this backup.
tar c /var/lib/apt/lists | gzip -1 > /tmp/var_lib_apt_lists.tgz
