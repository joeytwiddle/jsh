## Default behaviour is to display dropped lines in red, and new lines in white
## The option -oneway means dropped lines will not be reported.

## TODO: rename this script: it not proc related

BOTHWAYS=true
if test "$1" = -oneway
then BOTHWAYS=; shift
fi

FILEA="$1"
FILEB="$2"
shift
shift

## jfc bridge (for speed)
# if test `jwhich jfc`
# then JFCCOM="jfc simple oneway"
# else JFCCOM="jfcsh -sorted"
# fi
JFCCOM="jfcsh -sorted"

## Optionally, check for lines which have been dropped

if test "$BOTHWAYS"
then
	OTHER=`$JFCCOM "$FILEB" "$FILEA"`
	if ! test "$OTHER" = ""; then
		# echo
		# echo `cursered``cursebold`"<<< DIED:"
		cursered;cursebold
		echo "$OTHER"
		cursenorm
		# echo ">>>"`cursenorm`
		# echo
	fi
fi

## Optionally, check for lines which have been dropped

# cursegreen # ;cursebold
$JFCCOM "$FILEA" "$FILEB"
# cursenorm
