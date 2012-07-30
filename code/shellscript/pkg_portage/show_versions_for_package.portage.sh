PACKAGE="$1"
emerge -s "$PACKAGE" | grep -A2 "^.*/$PACKAGE$"
