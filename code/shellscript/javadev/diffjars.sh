## BUGS: Does not always delete .class files properly.  I suspect this is the $1 $2 inner class file labels being lost within withalldo - need escaping!

if [ ! "$1" ] || [ "$1" = --help ]
then
	echo
	echo "diffjars [ -src ] [ -diffcom <diffcom> ] <jar1> <jar2>"
	echo
	echo "  will extract each jar to a temporary directory, and compare the contents"
	echo "  using diffdirs or another <diffcom> if specified."
	echo
	echo "  -src : decompile with jad, and show the differences in java source."
	echo "         \"| more\" strongly recommended!"
	echo
	exit 1
fi

if [ "$1" = -src ]
then
	DECOMPILE=true; shift
	# JARDIFFCOM="diffsrcjars"
	JARDIFFCOM="diffdirs -showdiffswith diff"
fi

[ "$JARDIFFCOM" ] || JARDIFFCOM=diffdirs
if [ "$1" = -diffcom ]
then JARDIFFCOM="$2"; shift; shift
fi

JARADIR=`jgettmpdir "$1"`
JARBDIR=`jgettmpdir "$2"`

JARA=`realpath "$1"`
JARB=`realpath "$2"`

cd $JARADIR
jar xf "$JARA" &&
if [ "$DECOMPILE" ]
then
	if javadecompile 2>&1 | grep -v "^Parsing "
	then
		find $JARADIR -name "*.class" |
		withalldo rm
	fi
fi

cd $JARBDIR
jar xf "$JARB" &&
if [ "$DECOMPILE" ]
then
	if javadecompile 2>&1 | grep -v "^Parsing "
	then
		find $JARBDIR -name "*.class" |
		withalldo rm
	fi
fi

$JARDIFFCOM $JARADIR $JARBDIR

jdeltmp "$JARADIR" "$JARBDIR"
