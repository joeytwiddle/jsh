if [ "$1" = "" ] || [ "$1" = --help ]
then
  echo "diffcoms [ -vimdiff | -worddiff | -diffwith <diffcommand> ] <command_a> <command_b>"
  echo "  will run both commands, and diff their output."
  exit 1
fi

DIFFCOM="jfcsh -bothways"
while true
do
  case "$1" in
    -vimdiff)
      DIFFCOM="vimdiff"; shift
    ;;
    -worddiff)
      DIFFCOM="worddiff"; shift
    ;;
    -diffwith)
      DIFFCOM="$2"; shift; shift
    ;;
    *)
      break
    ;;
  esac
done

FILEX=`jgettmp "First com:  $1"`
FILEY=`jgettmp "Second com: $2"`

echo "$1" | sh > "$FILEX"
echo "$2" | sh > "$FILEY"

$DIFFCOM "$FILEX" "$FILEY"

jdeltmp "$FILEX" "$FILEY"
