if [ ! "$1" ] || [ "$1" = --help ]
then
cat << !

getpkgfromhwi <package_name>

  will log in to hwi, and bring back a tarfile of hwi's current installation
  of that package (all files listed by dpkg -L).

  Provided its dependencies are met, you might be able to use the package
  on another Linux system.
  (To do that, you could use ". includepath <path_to_untarred_package>".)

!
exit 1
fi

PKGNAME="$1"
# ssh joey@hwi.ath.cx "dpkg -L $PKGNAME | filesonly | withalldo tar cz" > $PKGNAME.fromhwi.tgz
# ssh joey@hwi.ath.cx "echo 'dpkg -L $PKGNAME | filesonly | withalldo tar cz' | jsh" > $PKGNAME.fromhwi.tgz
ssh joey@hwi.ath.cx "/home/joey/j/jsh -c 'dpkg -L $PKGNAME | filesonly | withalldo tar cz'" > $PKGNAME.fromhwi.tgz
## TODO: We are calling jsh on the remote machine (hwi).  So we may as well make that command into a script, eg. taruppkg
