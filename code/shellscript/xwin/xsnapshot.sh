# import -window root /tmp/screenshot-$$.bmp
# ## I think it would be good if:
# echo /tmp/screenshot-$$.bmp

DESTDIR=/tmp
DESTDIR="$HOME/screenshots" ; mkdir -p "$DESTDIR" || exit 1

if [ "$1" ]
then DESTINATION="$1"
else DESTINATION="$DESTDIR"/screenshot-$$.bmp
fi

TMPFILE=/tmp/screenshot-$$-tmp.bmp
import -window root "$TMPFILE"

if endswith "$DESTINATION" .bmp
then mv "$TMPFILE" "$DESTINATION"
else convert "$TMPFILE" "$DESTINATION"
fi

echo "$DESTINATION"
