# set -e
# set -x

## TODO: does not appear to clear bash history!!!

xhost
xhost - || error "Clearing xhost permissions failed."
jshinfo "NOTE: xhost permissions cleared, you will have to restore them manually"
## TODO: restore xhost permissions to previous when sbash is done
jshinfo

PRIVFILE="/home/joey/linux/.private/private.tgz.encrypted"
PRIVFILEDIR="`dirname "$PRIVFILE"`"
PRIVFILEBASE="`basename "$PRIVFILE" .tgz.encrypted`"

if test -e "$PRIVFILEDIR/$PRIVFILEBASE"
then
	jshinfo "[sbash] Refusing to decrypt over existing $PRIVFILEDIR/$PRIVFILEBASE."
	jshinfo "[sbash] Find running copy of sbash or clean up yourself."

	jshinfo "[sbash] Checking to see if old sbash is still running..."
	if findjob sbash | striptermchars | grep "\<sh [^ ]*sbash\>" | grep -v "\<$$\>"
	then exit 2
	fi
	jshinfo "[sbash] It isn't; I appear to be the only one."

	jshinfo "[sbash] Do you want to rejoin the old sbash session?"
	read ANSWER
	if [ ! "$ANSWER" = yes ]
	then exit 3
	fi

else

	if test ! -e "$PRIVFILE"
	then
		if test ! -e "$PRIVFILE.prev"
		then
			error "[sbash] No $PRIVFILE and no $PRIVFILE.prev; you need to set an existing PRIVFILE."
			exit 1
		fi
		jshwarn "[sbash] No $PRIVFILEBASE.tgz.encrypted found, using old $PRIVFILEBASE.tgz.encrypted.prev"
		cp -i "$PRIVFILE".prev "$PRIVFILE"
	fi

	cp "$PRIVFILE" "$PRIVFILE.sbash.bak" &&
	jshinfo "[sbash] Made backup in $PRIVFILE.sbash.bak" || exit 1
	cd "$PRIVFILEDIR"
	jshinfo "[sbash] In $PRIVFILEDIR"
	jshinfo "[sbash] Decrypting into $PRIVFILEBASE"
	decryptdir "$PRIVFILEBASE" || exit 1

fi

cd "$PRIVFILEDIR"
jshinfo "[sbash] Invoking shell in $PRIVFILEDIR/$PRIVFILEBASE"
cd "$PRIVFILEBASE" &&
bash ||
exit 4

jshinfo "[sbash] Calling: cd \"$PRIVFILEDIR\""
if cd "$PRIVFILEDIR"
then
	jshinfo "[sbash] Calling: encryptdir \"$PRIVFILEBASE\""
	if encryptdir "$PRIVFILEBASE"
	then
		jshinfo "[sbash] Calling: rm -rf \"$PRIVFILEDIR/$PRIVFILEBASE\""
		if rm -rf "$PRIVFILEDIR/$PRIVFILEBASE"
		then
			jshinfo "[sbash] ok" | highlight ok green
		else
			error "[sbash] Error re-encrypting, please archive $PRIVFILEDIR/$PRIVFILEBASE manually!"
		fi
	fi
fi

## TODO: this is a little dangerous, in the rare case that the user types the command, but forgets to type the last directory in the path,, in which case the automated backups and the current copy are lost!!!  Decrypt it somewhere else, and why not rm -rf it automatically.  Preserve a diff instead for the user (to delete) if they fear losing their changes.
