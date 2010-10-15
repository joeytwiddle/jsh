#!/bin/sh
echo "not written"
exit 0

MBOX=`jgettmp mbox.working`

cp "$1" "$MBOX"

while test ! `fileize "$MBOX"` = 0
do
	grep "Content-Length" ## Dammit not always there (for evolution mboxes anyway - maybe some processing cld put length in)!
