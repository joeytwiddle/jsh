# jsh-depends: cursebold cursecyan cursemagenta cursenorm rememo datediff jdeltmp jgettmpdir jgettmp newer realpath md5sum debug
# jsh-depends-ignore: arguments filename arguments todo

. jgettmpdir -top
MEMODIR=$TOPTMP/memo

## TODO:
#  - Allow user to specify their own hash (essentially making memo a hashtable)
#  - Leaves an empty or partial memo file if interrupted
#    We should memo to a temp file and move to memo file when complete
#  - Allow user to specify timeout after which rememo occurs
#  - Allow user to specify quick command which returns non-0 if rememo needed (or a test-rememo command?)
#  -                       a file (or indeed a directory full of files) which, if it is (they are) newer than the memo-cache-file, will force rememoing

if [ "$1" = "-info" ]
then
	MEMO_SHOW_INFO=true
	shift
fi

if [ "$1" = "" ] || [ "$1" = --help ]
then
	echo "Usage:"
  echo
	echo "  memo [options] <command>..."
  echo
	echo "  rememo <command>..."
  echo
  echo "    memo will cache the ouput of the given command, and redisplay it on future"
  echo "    calls made with the same arguments and from the same working directory."
  echo "    Hence memo is useful for caching the output of slow operations."
	echo "    You may use rememo to force a refresh of the cache for that command (in wd)."
  echo
	# echo "    will cache the output of the command (useful if it takes a long time to run),"
	# # echo "Memo will remember the output of <command> run in current working directory,
	# echo "    and redisplay this output on subsequent calls with the same arguments and working directory."
  echo "Options:"
  echo
  echo "  -t <time_period>  : force refresh of cache if given time period has expired"
  echo "  -f <filename>     : force refresh if file has changed since last caching"
  echo "  -d <dirname>      : force refresh if any file in given directory has changed"
  echo "  -c <test_command> : force refresh if command returns true"
  echo "                      (the command is evaluated with the memo file in \$FILE)"
  echo
  echo "Examples:"
  echo
  echo "  memo -f /var/lib/dpkg/status dpkg -l"
  echo "  memo -d /var/lib/apt apt-cache dump"
  echo "  memo -t '1 day' \"du -sk / | sort -n -k 1\""
  echo "  memo -c <check_com> (todo)"
  echo
	echo "Todo:"
  echo
  echo "  Possibly rememodiff which looks for changes since last memoed."
  echo
	exit 1
fi

[ "$REMEMOWHEN" ] || REMEMOWHEN='false' ## or whatever we think the default should be
while true
do
  case "$1" in
    -t)
      export TIME="$2"
      shift; shift
      REMEMOWHEN="$REMEMOWHEN"' || (
        touch -d "$TIME ago" $TMPFILE
        newer $TMPFILE "$FILE"
      )'
    ;;
    -f)
      export CHECKFILE="$2"
      shift; shift
      REMEMOWHEN="$REMEMOWHEN"' || newer "$CHECKFILE" "$FILE"'
    ;;
    -d)
      export CHECKDIR="$2"
      shift; shift
      REMEMOWHEN="$REMEMOWHEN"' || ( find "$CHECKDIR" -newer "$FILE" | grep "^" > /dev/null ) '
    ;;
    -c)
      REMEMOWHEN="$REMEMOWHEN || ( $2 )"
      shift; shift
    ;;
    *)
      break
    ;;
  esac
done

REALPWD=`realpath "$PWD"`
CKSUM=`echo "$*" | md5sum`
NICECOM=`echo "$REALPWD: $@.$CKSUM" | tr " /" "_+" | sed 's+\(................................................................................\).*+\1+'`
FILE="$MEMODIR/$NICECOM.memo"
TMPFILE=`jgettmp check_age`
export CHECKDIR CHECKFILE REMEMOWHEN FILE TMPFILE

# [ "$DEBUG" ] && debug "memo:     `cursemagenta`checking: $REMEMOWHEN (FILE=$FILE)`cursenorm`"

# echo "Doing check: $REMEMOWHEN" >&2
if [ "$REMEMO" ] || [ ! -f "$FILE" ] || eval "$REMEMOWHEN"
then
	# eval "$REMEMOWHEN" && [ "$DEBUG" ] && debug "memo:     `cursemagenta`Refresh needed with com: $REMEMOWHEN`cursenorm`"
	rememo "$@"
else
	[ "$DEBUG" ] && debug "memo:     `cursemagenta`$*`cursenorm`"
	cat "$FILE"
fi

jdeltmp $TMPFILE

if [ "$MEMO_SHOW_INFO" ]
then

	TMPF=`jgettmp`
	touch "$TMPF"
	(
		cursecyan
		# echo "as of "`date -r "$FILE"`
		echo "$@"
		TIMEAGO=`datediff -files "$FILE" "$TMPF"`
		echo "as of $TIMEAGO ago."
		cursenorm
	) >&2
	jdeltmp "$TMPF"

fi
