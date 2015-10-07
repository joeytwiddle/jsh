#!/bin/sh
# jsh-ext-depends: diff
# jsh-depends-ignore: memo rememo

#WC_OPTION="-l" ; UNIT_TYPE="l"
WC_OPTION="-c" ; UNIT_TYPE="c"

REMOVED=`diff "$@" | grep "^<" | wc $WC_OPTION`
CHANGED=`diff "$@" | grep "^|" | wc $WC_OPTION`
ADDED=`diff "$@" | grep "^>" | wc $WC_OPTION`

# echo "$* [$REMOVED removed, $CHANGED changed, $ADDED added]"

# [ "$REMOVED" = 0 ] && REMOVED= || REMOVED=" $REMOVED removed"
# [ "$CHANGED" = 0 ] && CHANGED= || CHANGED=" $CHANGED changed"
# [ "$ADDED" = 0 ] && ADDED= || ADDED=" $ADDED added"
# ADDED="$ADDED "

[ "$REMOVED" = 0 ] && REMOVED= || REMOVED="-$REMOVED"
[ "$CHANGED" = 0 ] && CHANGED= || CHANGED="~$CHANGED"
[ "$ADDED" = 0 ] && ADDED= || ADDED="+$ADDED"
if [ "x$REMOVED$CHANGED$ADDED" = "x" ]
then
	if cmp "$1" "$2" >/dev/null
	then UNIT_TYPE="no changes"
	else UNIT_TYPE="binaries differ"
	fi
fi
echo "\"$1\" \"$2\" [$REMOVED$CHANGED$ADDED$UNIT_TYPE]"
