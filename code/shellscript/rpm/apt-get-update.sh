# apt-get --config-file /root/apt-get-update-all-config.cfg update
apt-get --option Dir::Etc::sourcelist=/etc/apt/all-sources.list update
tar c /var/lib/apt/lists | gzip -1 > /tmp/var_lib_apt_lists.tgz
