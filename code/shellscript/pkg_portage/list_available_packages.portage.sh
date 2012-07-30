# cd /usr/portage/metadata/cache
cd /var/cache/edb/dep/usr/portage
find -mindepth 2 -maxdepth 2 | sed 's+^./++'
