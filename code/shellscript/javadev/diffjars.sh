[ "$JARDIFFCOM" ] || JARDIFFCOM=diffdirs
if [ "$1" = -diffcom ]
then JARDIFFCOM="$2"; shift; shift
fi

JARA=`realpath "$1"`
JARB=`realpath "$2"`

JARADIR=`jgettmpdir "$JARA"`
JARBDIR=`jgettmpdir "$JARB"`

cd $JARADIR
jar xf "$JARA"

cd $JARBDIR
jar xf "$JARB"

$JARDIFFCOM $JARADIR $JARBDIR

jdeltmp "$JARADIR" "$JARBDIR"
