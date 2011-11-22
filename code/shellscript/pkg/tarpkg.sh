for PKG
do
	dpkg -L "$PKG" |
	filesonly -inclinks |
	withalldo verbosely tar cfz /tmp/"$PKG".tgz
done

