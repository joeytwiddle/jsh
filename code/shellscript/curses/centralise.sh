# jsh-depends: strlen
PADLEFT=">"
PADBRACE=" "
PADRIGHT="<"

if [ "$1" = "" ] || [ "$1" = "--help" ]
then
	echo "centralise <string>"
	echo "centralise <padchars> <string>"
	echo "centralise [-pad] <padleft> <padbrace> <padright> <string>"
	exit 1
fi

if [ ! "$2" = "" ]
then
	if [ "$3" = "" ]
	then
		PADLEFT="$1"
		PADRIGHT="$1"
		shift
	else
		if [ "$1" = "-pad" ]
		then shift
		fi
		PADLEFT="$1"
		PADBRACE="$2"
		PADRIGHT="$3"
		shift; shift; shift
	fi
fi

STRING="$1"

if [ "$COLUMNS" = "" ]
then COLUMNS=80
fi
LEN=`strlen "$STRING"`
REMAINING=`expr "$COLUMNS" - "$LEN"`
LEFT=`expr "$REMAINING" / 2 - 2`
for X in `seq 1 $LEFT`
do printf "%s" "$PADLEFT"
done
printf "%s" "$PADBRACE$STRING$PADBRACE"
for X in `seq 1 $LEFT`
do printf "%s" "$PADRIGHT"
done
printf "\n"
