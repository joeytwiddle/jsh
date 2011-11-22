## Fast version:
# find "$@" -type l -not -xtype f -and -not -xtype d

## But I suspect this will return us symlinks to non-files and non-dirs, so...

if [ "$1" = -follow ]
then FOLLOW="-follow"; shift
fi

## Version with extra checking:
find "$@" -type l -not -xtype f -and -not -xtype d $FOLLOW |
while read FILE
do
	if [ -L "$FILE" ] && [ ! -e "$FILE" ]
	then echo "$FILE"
	else jshwarn "findbrokenlinks made a mistake with: $FILE"
	fi
done
