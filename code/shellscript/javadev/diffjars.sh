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
[ "$DECOMPILE" ] && javadecompile 2>&1 | grep -v "^Parsing " && find $JARADIR -type "*.class" | withalldo rm

cd $JARBDIR &&
jar xf "$JARB" &&
[ "$DECOMPILE" ] && javadecompile 2>&1 | grep -v "^Parsing " && find $JARBDIR -type "*.class" | withalldo rm

$JARDIFFCOM $JARADIR $JARBDIR

jdeltmp "$JARADIR" "$JARBDIR"
