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

JARA=`realpath "$1"`
JARB=`realpath "$2"`

JARADIR=`jgettmpdir "$JARA"`
JARBDIR=`jgettmpdir "$JARB"`

cd $JARADIR &&
jar xf "$JARA" &&
[ "$DECOMPILE" ] && javadecompile 2>&1 | grep -v "^Parsing " && find $JARADIR -name "*.class" | withalldo rm

cd $JARBDIR &&
jar xf "$JARB" &&
[ "$DECOMPILE" ] && javadecompile 2>&1 | grep -v "^Parsing " && find $JARBDIR -name "*.class" | withalldo rm

$JARDIFFCOM $JARADIR $JARBDIR

# jdeltmp "$JARADIR" "$JARBDIR"
