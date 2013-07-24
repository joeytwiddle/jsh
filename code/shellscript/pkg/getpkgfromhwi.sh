#!/bin/sh

## See also: dpkg-repack
## Or for gentoo: quickpkg ?

if [ ! "$1" ] || [ "$1" = --help ]
then
cat << !

getpkgfromhwi [ -unpack ] <package_name>

  will log in to hwi, and bring back a tarfile of hwi's current installation
  of that package (all files listed by dpkg -L).

  Provided its dependencies are met, you might be able to use the package
  on another Linux system.
  (To do that, you could use ". includepath <path_to_untarred_package>".)

  with -unpack, instead of creating a file, the archive is immediately expanded into .

!
exit 1
fi

if [ "$1" = -unpack ]
then UNPACK=1 ; shift
fi

for PKGNAME
do
	# ssh joey@hwi.ath.cx "dpkg -L $PKGNAME | filesonly -inclinks | withalldo tar cz" > $PKGNAME.fromhwi.tgz
	# ssh joey@hwi.ath.cx "echo 'dpkg -L $PKGNAME | filesonly -inclinks | withalldo tar cz' | jsh" > $PKGNAME.fromhwi.tgz
	# ssh joey@hwi.ath.cx \
	# verbosely ssh joey@hwi.ath.cx -p 222 "/home/joey/j/jsh -c 'dpkg -L $PKGNAME | filesonly -inclinks | verbosely withalldo tar cz'" |
	verbosely ssh joey@hwi.ath.cx -p 222 "dpkg -L $PKGNAME | j/jsh filesonly -inclinks | j/jsh withalldo tar cjv" |
	if [ "$UNPACK" ]
	then tar xj
	else cat > $PKGNAME.fromhwi.tar.bz2
	fi
	[ "$?" = 0 ] || jshwarn "FAILED to get package $PKGNAME"
	## TODO: We are calling jsh on the remote machine (hwi).  So we may as well make that command into a script, eg. taruppkg
done
