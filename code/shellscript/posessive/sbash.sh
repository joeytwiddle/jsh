# set -e
# set -x

xhost
xhost - || error "Clearing xhost permissions failed."
echo "NOTE: xhost permissions cleared, you will have to restore them manually"
## TODO: restore xhost permissions to previous when sbash is done
echo

PRIVFILE="/home/joey/linux/.private/private.tgz.encrypted"
PRIVFILEDIR="`dirname "$PRIVFILE"`"
PRIVFILEBASE="`basename "$PRIVFILE" .tgz.encrypted`"

if test -e "$PRIVFILEDIR/$PRIVFILEBASE"
then
	echo "sbash: Refusing to decrypt over existing $PRIVFILEDIR/$PRIVFILEBASE."
	echo "sbash: Find running copy of sbash or clean up yourself."

	echo "sbash: Checking to see if old sbash is still running..."
	if findjob sbash | striptermchars | grep "\<sh [^ ]*sbash\>" | grep -v "\<$$\>"
	then exit 2
	fi
	echo "sbash: It isn't; I appear to be the only one."

	echo "sbash: Do you want to rejoin the old sbash session?"
	read ANSWER
	if [ ! "$ANSWER" = yes ]
	then exit 3
	fi

else

	if test ! -e "$PRIVFILE"
	then
		if test ! -e "$PRIVFILE.prev"
		then
			echo "sbash: No $PRIVFILE and no $PRIVFILE.prev; you need to set an existing PRIVFILE."
			exit 1
		fi
		echo "sbash: No $PRIVFILEBASE.tgz.encrypted found, using old $PRIVFILEBASE.tgz.encrypted.prev"
		cp -i "$PRIVFILE".prev "$PRIVFILE"
	fi

	cp "$PRIVFILE" "$PRIVFILE.sbash.bak" &&
	echo "sbash: Made backup in $PRIVFILE.sbash.bak" || exit 1
	cd "$PRIVFILEDIR"
	echo "sbash: In $PRIVFILEDIR"
	echo "sbash: Decrypting into $PRIVFILEBASE"
	decryptdir "$PRIVFILEBASE" || exit 1

fi

cd "$PRIVFILEDIR"
echo "sbash: Invoking shell in $PRIVFILEDIR/$PRIVFILEBASE"
cd "$PRIVFILEBASE" &&
bash ||
exit 4

cd "$PRIVFILEDIR" &&
encryptdir "$PRIVFILEBASE" &&
rm -rf "$PRIVFILEDIR/$PRIVFILEBASE" ||
echo "sbash: Error re-encrypting, please archive $PRIVFILEDIR/$PRIVFILEBASE manually!"

## TODO: this is a little dangerous, in the rare case that the user types the command, but forgets to type the last directory in the path,, in which case the automated backups and the current copy are lost!!!  Decrypt it somewhere else, and why not rm -rf it automatically.  Preserve a diff instead for the user (to delete) if they fear losing their changes.
