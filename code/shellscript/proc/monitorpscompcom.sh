if test `jwhich jfc`
then JFCCOM="jfc simple oneway"
else JFCCOM="jfcsh"
fi

if test "$1" = "-ungrep"
then UNGREP="$2"; shift; shift
fi

FILEA="$1"
FILEB="$2"
shift
shift

OTHER=`$JFCCOM "$FILEB" "$FILEA" | ungrep $UNGREP`
if ! test "$OTHER" = ""; then
  # echo
  # echo `cursered``cursebold`"<<< DIED:"
  cursered;cursebold
  echo "$OTHER"
  cursenorm
  # echo ">>>"`cursenorm`
  # echo
fi
# cursegreen # ;cursebold
$JFCCOM "$FILEA" "$FILEB" | ungrep $UNGREP
# cursenorm
