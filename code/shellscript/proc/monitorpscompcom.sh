if test "$1" = "-ungrep"
then UNGREP="$2"; shift; shift
fi

FILEA="$1"
FILEB="$2"
shift
shift

OTHER=`jfc simple oneway "$FILEB" "$FILEA" | ungrep "$UNGREP"`
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
jfc simple oneway "$FILEA" "$FILEB" | ungrep "$UNGREP"
# cursenorm
