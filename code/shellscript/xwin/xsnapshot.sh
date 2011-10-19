#!/bin/sh
# import -window root /tmp/screenshot-$$.bmp
# ## I think it would be good if:
# echo /tmp/screenshot-$$.bmp

DESTDIR=/tmp
DESTDIR="$HOME/screenshots" ; mkdir -p "$DESTDIR" || exit 1

if [ "$1" ]
then DESTINATION="$1"
else DESTINATION="$DESTDIR"/screenshot-$$.png
fi

## ATM we force output as .bmp because other programs may be expecting .bmps.
## But we could just scrap compatibility with them, and save pngs instead (much smaller but require processing).

TMPFILE=/tmp/screenshot-$$-tmp.bmp
import -window root "$TMPFILE"

# if endswith "$DESTINATION" .bmp
# then mv "$TMPFILE" "$DESTINATION"
# else convert "$TMPFILE" "$DESTINATION"
# fi
nice -n 5 convert "$TMPFILE" "$DESTINATION" && rm -f "$TMPFILE"

echo "$DESTINATION"
