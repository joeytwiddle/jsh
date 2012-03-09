#!/bin/sh
if [ "$1" = "" ] || [ "$1" = --help ]
then
  echo "diffcoms [ -color | -vimdiff | -worddiff | -diffwith <diffcommand> ] \"<command_a>\" \"<command_b>\""
  echo "  will run both commands, using eval, and diff their output."
  exit 1
fi

DIFFCOM="jfcsh -bothways"
# DIFFCOM=prettydiff      # normal > < diff but highlighted
# DIFFCOM=jdiff         # side-by-side
# DIFFCOM=jdiffsimple   # no > < + - markers just colors
## None of the above trim 
while true
do
  case "$1" in
    -color)
      DIFFCOM="jdiffsimple -fine"; shift
    ;;
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

## Doesn't let you do pipes within the command:
# echo "$1" | sh > "$FILEX"
# echo "$2" | sh > "$FILEY"
eval "$1" > "$FILEX"
eval "$2" > "$FILEY"

$DIFFCOM "$FILEX" "$FILEY"

jdeltmp "$FILEX" "$FILEY"
