# set -e
# set -x

PRIVFILE="/home/joey/private.tgz.encrypted"
PRIVFILEDIR="`dirname "$PRIVFILE"`"
PRIVFILEBASE="`basename "$PRIVFILE" .tgz.encrypted`"

if test -e "$PRIVFILEDIR/$PRIVFILEBASE"
then
	echo "sbash: Refusing to decrypt over existing $PRIVFILEDIR/$PRIVFILEBASE."
	echo "sbash: Find running copy of sbash or clean up yourself."
	exit 1
fi

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

echo "sbash: Invoking shell in $PRIVFILEDIR/$PRIVFILEBASE"
cd "$PRIVFILEBASE"
bash

cd "$PRIVFILEDIR"
encryptdir "$PRIVFILEBASE" &&
echo "sbash: You should rm -rf $PRIVFILEDIR/$PRIVFILEBASE" ||
echo "sbash: Error re-encrypting, please archive $PRIVFILEDIR/$PRIVFILEBASE manually!"
