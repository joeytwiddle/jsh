# jsh-ext-depends-ignore: apt-cache dpkg find dirname last sort from file time realpath
# jsh-ext-depends: sed md5sum newer
# jsh-depends: cursebold cursecyan cursemagenta cursenorm rememo datediff jdeltmp jgettmpdir jgettmp newer realpath debug
# this-script-does-not-depend-on-jsh: arguments filename arguments todo mytest md5sum

## TODO: an option to cache until condition expires: that date of memofile == date of specified file (in other words newer || older)

export DEBUG_MEMO=true ## until i work out what memos are filling up /tmp (maybe 

## Note: if you see a script which does "cd /" and claims to do it for memoing, this is because it wants all its memo's to be "working-directory independent"
##       this might be solved in future by TODO: an option (or envvar) to specify that the working-directory is irrelevant to memo's output, and should be ignored in the hash

## TODO: I don't think there is an option (eg. exported env var) to force execution of the command directly without creating the cachefile, but there should be.

## Consider: memo is currently responds like dog, outputting nothing until the process has finished running.  It might be desirable to change this in the future, so that it outputs while it receives input (maybe buffered at each line), in which case an option should be made (and used elsewhere) now to force the dog-like behaviour.  And btw, should dog or pipebackto have this behaviour changed?

## DONE: added efficiency here if . jgettmpdir -top is run before using memo
[ -w "$TOPTMP" ] || . jgettmpdir -top
MEMODIR=$TOPTMP/memo

## TODO:
#  - Allow user to specify their own hash (essentially making memo a hashtable)

## TODO: there are two main things slowing it down:
##       the realpath     : well, move jsh realpath out of the way for a start!
##                        : DONE: add the -nd option, because there's no point doing realpath if cd / has already been done to prevent cwd hashing
##                        : if realpath slows it down, then just use $PWD, it's not that much of a feature loss (memo's from different $PWD's will fail even if `realpath $PWD` is identical)
##                          don't do realpath on /!   OK it doesn't do realpath on /, which helped a lot for scripts which call memo after cd /
##       the checksumming : is there a quicker hash we can use in the shell?
## Afterthought: another factor may be the damn size of this script!
##               but DONE :) as far as checksumming is concerned, I think we should only try to include the command in the memofile name if we are in debug mode, because that may be slowing it down.
## Could strip unneeded comments, and move then to after the end of the script (ahh there is no return or exit here)

## HOW-TO-SPEED-IT-UP-EXTERNALLY: Yes the re-parsing of this script does slow it down considerably; this can be improved by using ". importshfn rememo" and ". importshfn memo" before repeatedly using memo.  :)

## DONE: refactor the destination nonsense out of memo/rememo to somewhere common!  (Well actually we could pass it to rememo :)

## DONE:
#  - Leaves an empty or partial memo file if interrupted
#    We should memo to a temp file and move to memo file when complete
#  - Allow user to specify timeout after which rememo occurs
#  - Allow user to specify quick command which returns non-0 if rememo needed (or a test-rememo command?)
#  -                       a file (or indeed a directory full of files) which, if it is (they are) newer than the memo-cache-file, will force rememoing

## DONE: added efficiency by referring to md5sum binary directly to avoid jsh's md5sum from being called.
## but TODO NOTE BUG: this is NOT good if there is no md5sum binary!  :/
## so TODO: What is the efficient way to select which md5sum command to use?

## DONE: allow the default memo-ing condition and/or command to be provided as an env-var :) .  Oh yeah, it's REMEMOWHEN!



### Parse command-line arguments:

if [ "$1" = "-info" ]
then
	MEMO_SHOW_INFO=true
	shift
fi

if [ "$1" = "" ] || [ "$1" = --help ]
then
	more << !

Usage:

  memo [options] <command>...

  rememo <command>...

    memo will cache the ouput of the given command, and redisplay it on future
    calls made with the same arguments and from the same working directory.
    Hence memo is useful for caching the output of slow operations.
    You may use rememo to force a refresh of the cache for that command (in wd).

Options:

  -t <time_period>  : force refresh of cache if given time period has expired
  -f <filename>     : force refresh if file has changed since last caching
  -d <dirname>      : force refresh if any file in given directory has changed
  -c <test_command> : force refresh if command returns true
                      (the command is evaluated with the memo file in $MEMOFILE)

  If the command+args and directory alone do not distinguish two distinct memos,
  you can export further details about the memo's environment in MEMOEXTRA.

Examples:

  memo -f /var/lib/dpkg/status dpkg -l
  memo -d /var/lib/apt apt-cache dump
  memo -t '1 day' eval "du -sk /* | sort -n -k 1"   (using eval the | is memoed)
  memo -c <check_com>  (eh what's this for?)

Todo:

  Possibly rememodiff which looks for changes since last memoed.

Bugs:

  -d <dirname> and -f <filename> compare the modified time against the modified time of the memo.
    If the memo takes a long time to generate, it may be that the files changed since it started,
    but before it ended, and so it should be rememo-ed, but isn't.  Could solve by changing
    finished memofile's modified date to time that it was started.

!

  exit 1
fi

if [ "$1" = -nd ]
then MEMO_IGNORE_DIR=true; shift
fi

### How often should we re-generate the cached file?  We parse arguments to find out.
## Set default REMEMOWHEN if none exist in env, and no options were given to memo.
AGEFILE=`jgettmp check_age`
[ "$REMEMOWHEN" ] || echo "$1" | grep "^-" >/dev/null || REMEMOWHEN='( touch -d "5 minutes ago" $AGEFILE ; newer $AGEFILE "$MEMOFILE" )' ## if there were no timeout options given and no REMEMOWHEN exported, we default to 5 minute cachefiles.
## If we are about to add conditions, we do this with OR, so we must start with false.  TODO: what if no conditions are provided?  We will never rememo, since we don't drop back to the default.
[ "$REMEMOWHEN" ] || REMEMOWHEN='false' ## or whatever we think the default should be: 1min, 5mins or 1hour; guess from files in arguments?!
## ah no but if any of the following cmdline options are used, then idd rememowhen *should* begin false (at least that's the way we are doing it atm)
while true
do
  case "$1" in
    -t)
      export TIME="$2"
      [ "$OVERRIDE_TIME" ] && TIME="$OVERRIDE_TIME"
      shift; shift
      REMEMOWHEN="$REMEMOWHEN"' || (
        touch -d "$TIME ago" $AGEFILE
        newer $AGEFILE "$MEMOFILE"
      )'
    ;;
    -f)
      export CHECKFILE="$2"
      shift; shift
      REMEMOWHEN="$REMEMOWHEN"' || newer "$CHECKFILE" "$MEMOFILE"'
    ;;
    -d)
      export CHECKDIR="$2"
      shift; shift
      REMEMOWHEN="$REMEMOWHEN"' || ( find "$CHECKDIR" -newer "$MEMOFILE" | grep "^" > /dev/null ) '
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



### Work out the name for the cachefile:

if [ "$MEMO_IGNORE_DIR" ] || [ "$PWD" = / ] ## for speed or wider memoing (if cwd is irrelevant to result)
then REALPWD=/
else REALPWD=`realpath "$PWD"`
fi
# CKSUM=`echo "$REALPWD/$*" | /usr/bin/md5sum`
CKSUM=`echo "[$MEMOEXTRA]$REALPWD/$*" | /usr/bin/cksum -` ## seems minutely faster to me
if [ "$DEBUG_MEMO" ]
then NICECOM=`echo "[$MEMOEXTRA]$CKSUM..$*..$REALPWD" | tr " \n/" "__+" | sed 's+\(................................................................................\).*+\1+'`
else NICECOM="$CKSUM"
fi
MEMOFILE="$MEMODIR/$NICECOM.memo"
export CHECKDIR CHECKFILE REMEMOWHEN MEMOFILE AGEFILE

# [ "$DEBUG" ] && debug "memo:     `cursemagenta`checking: $REMEMOWHEN (MEMOFILE=$MEMOFILE)`cursenorm`"



### Decide whether we need to build the cachefile, and either call rememo to build it, or cat it directly.

# echo "Doing check: $REMEMOWHEN" >&2
if [ "$REMEMO" ] || [ ! -f "$MEMOFILE" ] || eval "$REMEMOWHEN"
then
	# [ "$DEBUG" ] && ( debug "REmemoing: com=\"$NICECOM\" REMEMO=$REMEMO filecached=`mytest test -f \"$MEMOFILE\"` REMEMOWHEN=$REMEMOWHEN" | tr '\n' ';' ; echo>&2 )
	[ "$DEBUG" ] && debug "memo: re-running com=\"$NICECOM\" REMEMO=$REMEMO filecached=`mytest test -f \"$MEMOFILE\"` REMEMOWHEN=$REMEMOWHEN"
	# eval "$REMEMOWHEN" && [ "$DEBUG" ] && debug "memo:     `cursemagenta`Refresh needed with com: $REMEMOWHEN`cursenorm`"
	[ "$MEMO_SHOW_NEW_CACHEFILES" ] && jshinfo "memo: creating new cachefile from command: `cursebold`$NICECOM > \"$MEMOFILE\""
	# [ "$MEMO_SHOW_INFO" ] && jshinfo "Calling: rememo $*" && SHOW_INFO_DONE=true
	if [ "$MEMO_SHOW_INFO" ]
	then
		if [ -f "$MEMOFILE" ]
		# then jshinfo "Replacing old memo: rememo $*" && SHOW_INFO_DONE=true
		then jshinfo "Replacing old memo: $MEMOFILE"
		# else jshinfo "Building new memo: rememo $*" && SHOW_INFO_DONE=true
		else jshinfo "Output will be cached.  Retrieve with: memo $*" && SHOW_INFO_DONE=true
		fi
	fi
	rememo "$@"
	## TODO CONSIDER: If we did . rememo "$@" here, maybe functions would get called :)  Although if we have done importshfn memo, then that might achieve the same.
else
	# [ "$DEBUG" ] && debug "memo: re-using com=\"$NICECOM\""
	[ "$DEBUG" ] && debug "memo: re-using memofile=\"$MEMOFILE\""
	cat "$MEMOFILE"
fi
EXITWITH="$?"

[ "$AGEFILE" ] && jdeltmp $AGEFILE

if [ "$MEMO_SHOW_INFO" ] && [ ! "$SHOW_INFO_DONE" ]
then

	if [ -f "$MEMOFILE" ]
	then
		TMPF=`jgettmp` ## make a temporary "now" file
		touch "$TMPF"
		(
			cursecyan
			# echo "as of "`date -r "$MEMOFILE"`
			# echo "% $@"
			TIMEAGO=`datediff -files "$MEMOFILE" "$TMPF"`
			echo "\"$*\" cached $TIMEAGO ago, in file \"$MEMOFILE\""
			cursenorm
		) >&2
		jdeltmp "$TMPF"
	else
		: ## memo failed to produce a file; due to invalid command?
	fi

fi
SHOW_INFO_DONE=

[ "$EXITWITH" = 0 ]
