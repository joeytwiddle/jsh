#!/bin/sh

# jsh-ext-depends: sed md5sum newer find realpath
# jsh-ext-depends-ignore: apt-cache dpkg dirname last sort from file time spam compare
# jsh-depends: cursebold cursecyan cursemagenta cursenorm rememo datediff jdeltmp jgettmpdir jgettmp newer debug jshwarn jshinfo
# jsh-depends-ignore: arguments filename arguments todo mytest md5sum realpath HOME cursegreen duskdiff before find deprecated

## This script may not look pretty, but it is an awesome feature.

## TODO: Needs an overhaul.  Far too slow.
##       Should take fast branches more often.
##       Don't use md5sum if we're already creating unique human-readable label.
##       rememo should do nothing except call memo; memo should build, read and cleanup cachefiles.
##       the sh can be improved, but a bash fork might go faster

## TODO: getmemofile should be refactored out of memo and rememo, so that apps
##       can get it if needed.
##       For example, that app can be much faster directly grepping the file,
##       rather than asking memo for the file contents, and grepping the stream
##       In this respect, the caller might want memo to generate the file if
##       none exists.

## TODO: By default jsh should import these scripts as functions on startup.
##       But they should still work properly even if they were not sourced.

## TODO: an option to cache until condition expires: that date of memofile == date of specified file (in other words newer || older)

export DEBUG_MEMO=true ## TODO DEV TOREMOVE: until i work out what memos are filling up /tmp

## Note: if you see a script which does "cd /" and claims to do it for memoing, this is because it wants all its memo's to be "working-directory independent"
##       this might be solved in future by TODO: an option (or envvar) to specify that the working-directory is irrelevant to memo's output, and should be ignored in the hash
##       Surely DONE by passing -nd or setting MEMO_IGNORE_DIR

## TODO: I don't think there is an option (eg. exported env var) to force execution of the command directly without creating the cachefile, but there should be.

## Consider: memo is currently responds like dog, outputting nothing until the process has finished running.  It might be desirable to change this in the future, so that it outputs while it receives input (maybe buffered at each line), in which case an option should be made (and used elsewhere) now to force the dog-like behaviour.  And btw, should dog or pipebackto have this behaviour changed?

### BUG: $USER should be the owner of $MEMODIR, and everything below it.  The MEMODIR of barry should never be exported to and used by root (can happen sometimes through su).
## DONE: added efficiency here if . jgettmpdir -top is run before using memo
# [ -w "$TOPTMP" ] || . jgettmpdir -top
# MEMODIR=$TOPTMP/memo
for MEMODIR in "$MEMODIR" "$HOME/.memos" "/tmp/memodir-`whoami`" ""
do
	[ -n "$MEMODIR" ] || continue
	if [ -w "$MEMODIR" ]
	then break
	fi
	mkdir -p "$MEMODIR" 2>/dev/null && break
done

if [ ! "$MEMODIR" ] || [ ! -w "$MEMODIR" ]
then
	jshwarn "Can not performing memoing - No writeable MEMODIR!  ($MEMODIR)"
	exit 2
fi

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

    You may use rememo to force a refresh of the cache for that command.

    The timeout for cached data is 5 minutes, unless options override it.

Options:

  -t <time_period>  : force refresh of cache if given time period has expired
  -f <filename>     : force refresh if file has changed since last caching
  -d <dirname>      : force refresh if any file below given directory has changed
  -c <test_command> : force refresh if command returns true
                      (the command is passed \$MEMOFILE as its argument)

  If the command+args and directory alone do not distinguish two distinct memos,
  you can export further details about the memo's environment in MEMOEXTRA.

  If multiple conditions are given, any one of them can force a rememo.

Examples:

  memo -f /var/lib/dpkg/status dpkg -l
  memo -d /var/lib/apt apt-cache dump
  memo -t '1 day' eval "du -sk /* | sort -n -k 1"   (using eval the | is memoed)
  memo -c false some_heavy_process                  (never refresh this!)

Todo:

  Possibly rememodiff which looks for changes since last memoed.
  See duskdiff for an example of this.

Environment variables / options:

  REMEMOWHEN    Instead of passing conditions as arguments, you can pass a
                command here which will force rememoing if it returns non-zero
                status.

  MEMO_IGNORE_DIR         If unset, memos are cached per-current-folder.
                          Set this if your command is cwd-invariant.

    (Note it actually forces the path in the memofile to '/' so it could
    conflict with a per-dir memo done on '/' but it is unlikely that a user
    will ever memo the same cmd with and without MEMO_IGNORE_DIR.)

    memo -nd ... is deprecated in favour of MEMO_IGNORE_DIR=1 memo ...

      Whilst -nd is nice and simple, it is inefficient due to arg parsing.
      Also it is parsed only if it is the first arg!

  MEMO_IGNORE_EXITCODE    When unset, non-zero exit codes prevent data caching.
                          Set this if you want to cache stdout even if it errors.

  TODO: MEMO_SIMPLE_CMD   Could be set by the user if they know the length of
                          the command+args will not be too long *and* not
                          contain any weird chars.  In this case the MEMOFILE
                          can use the cmd+args directly as the filename, which
                          saves time usually spent filtering weird chars and
                          checksumming potentially-too-long cmds.

    (Note: '/'s in the path and args are currently replaced by '#'s but this
    could theoretically create overlap.  Better might be to encode all
    problematic chars to "@NN" format, including '@'.)

Display options:

  MEMO_SHOW_NEW_CACHEFILES   Alternative to setting the two below!  This would
                             be a good default enabled, with a setting to allow
                             scripts to disable it.  We could deprecate the two
                             below and introduce MEMO_HIDE_INFO and
                             MEMO_VERBOSE?  Or keep MEMO_SHOW_INFO and
                             introduce MEMO_QUIET / -q.

  MEMO_SHOW_INFO          Show what is going on (useful).

  MEMO_NOSHOW_REUSE       Only show when working hard, not when using cache.
                          Prevents spam when memo is working well.
                          Only relevant if MEMO_SHOW_INFO is set.

Bugs:

  -d <dirname> and -f <filename> compare the modified time against the modified
    time of the memo.  If the memo takes a long time to generate, it may be
    that the files changed since it started, but before it ended, and so it
    should be rememo-ed, but isn't.  Could solve by changing finished
    memofile's modified date to time that it was started.

Notes:

  The argument for exposing features via environment vars rather whan
  command-line arguments is that argument parsing has an overhead.

!

## (further waffle)
# The conclusion is therefore that environment vars should always be available
# as an option to avoid args, and used at the discretion of the caller when
# efficiency is required.  However args may be useful for rapid development,
# and end users, so many/all features should be available as args too.  The
# brevity of args are an advantage, and can be easier to remember: environment
# vars are prone to typos due to their expansive namespacing.

  exit 1
fi

if [ "$1" = -nd ]
then MEMO_IGNORE_DIR=true; shift
fi

### How often should we re-generate the cached file?  We parse arguments to find out.
AGEFILE=`jgettmp check_age`
## Set the default REMEMOWHEN condition if none exist in env, and no options were given to memo.  (Done after -nd).
[ -n "$REMEMOWHEN" ] || echo "$1" | grep "^-" >/dev/null || REMEMOWHEN='( touch -d "5 minutes ago" $AGEFILE ; newer $AGEFILE "$MEMOFILE" )' ## if there were no timeout options given and no REMEMOWHEN exported, we default to 5 minute cachefiles.
## If we are about to add conditions, we do this with OR, so we must start with false.  TODO: what if no conditions are provided?  We will never rememo, since we don't drop back to the default.
[ -n "$REMEMOWHEN" ] || REMEMOWHEN='false' ## or whatever we think the default should be: 1min, 5mins or 1hour; guess from files in arguments?!
## ah no but if any of the following cmdline options are used, then idd rememowhen *should* begin false (at least that's the way we are doing it atm)
while true
do
  case "$1" in
    -t)
      ## TODO: The default rule might be time-based.  If so, we want to override it with this user (dev) supplied value.
      ## AFAIK TIME and OVERRIDE_TIME are never used!
      export TIME="$2"
      [ -n "$OVERRIDE_TIME" ] && TIME="$OVERRIDE_TIME"
      shift; shift
      REMEMOWHEN="$REMEMOWHEN"' || ( touch -d "$TIME ago" $AGEFILE ; newer $AGEFILE "$MEMOFILE" )'
      ## TODO CONSIDER: This pattern is used again above - push it to a function or another script?
      ## TODO CONSIDER: Also there is no need to use an AGEFILE.  We can use date +%s -d "$TIME ago" or -r "$MEMOFILE" to get two numbers, and compare them in the shell.
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



### {{{ Generate MEMOFILE filename
### Work out the name for the cachefile:
if [ -n "$MEMO_IGNORE_DIR" ] || [ "$PWD" = / ] ## for speed or wider memoing (if cwd is irrelevant to result)
then REALPWD=/
else REALPWD="`realpath "$PWD"`"
fi
## DEBUG_MEMO sacrifices speed for meaningful memofile names:
if [ -n "$DEBUG_MEMO" ]
# then CKSUM="` echo -n "$MEMOEXTRA[$*][$REALPWD" | tr " \n/" "_|#" | sed 's+^\(.\{80\}\).*+\1...+' `].$CKSUM"
then CKSUM="` echo -n "$MEMOEXTRA[$*][$REALPWD" | tr " \n/" "_|#" | sed 's+^\(.\{80\}\).*+\1...+' `].$CKSUM"
else CKSUM="`echo "[$MEMOEXTRA]$REALPWD/$*" | /usr/bin/md5sum -`"
fi
MEMOFILE="$MEMODIR/$CKSUM.memo"
# [ -n "$DEBUG" ] && debug "[memo]     `cursemagenta`checking: $REMEMOWHEN (MEMOFILE=$MEMOFILE)`cursenorm`"
### }}}



### Decide whether we need to build the cachefile, and either call rememo to build it, or cat it directly.

# echo "Doing check: $REMEMOWHEN" >&2
if [ -n "$REMEMO" ] || [ ! -f "$MEMOFILE" ] || eval "$REMEMOWHEN"
then
	NICECOM="$*"
	[ -n "$DEBUG" ] && debug "[memo] re-running com=\"$NICECOM\" REMEMO=$REMEMO filecached=`mytest test -f \"$MEMOFILE\"` REMEMOWHEN=$REMEMOWHEN"
	# eval "$REMEMOWHEN" && [ -n "$DEBUG" ] && debug "[memo]     `cursemagenta`Refresh needed with com: $REMEMOWHEN`cursenorm`"
	# [ -n "$MEMO_SHOW_NEW_CACHEFILES" ] && jshinfo "[memo] creating new cachefile from command: `cursebold`$NICECOM > \"$MEMOFILE\""
	[ -n "$MEMO_SHOW_NEW_CACHEFILES" ] && jshinfo "[memo] caching: `cursegreen;cursebold`$NICECOM `cursenorm`> `cursecyan`$MEMOFILE`cursenorm`"
	## Use DEBUG instead of MEMO_SHOW_REASON!  This seems to have trouble with CHECKDIR, although it is exported fine!
	# [ -n "$MEMO_SHOW_REASON" ] && jshinfo "[memo] reason: REMEMO=$REMEMO MEMOFILE=`mytest [ -f "$MEMOFILE" ]` REMEMOWHEN=$REMEMOWHEN (`mytest eval "$REMEMOWHEN"`)"
	# [ -n "$MEMO_SHOW_INFO" ] && jshinfo "Calling: rememo $*" && SHOW_INFO_DONE=true
	if [ -n "$MEMO_SHOW_INFO" ]
	then
		if [ -f "$MEMOFILE" ]
		# then jshinfo "Replacing old memo: rememo $*" && SHOW_INFO_DONE=true
		then jshinfo "Replacing old memo: $MEMOFILE"
		# else jshinfo "Building new memo: rememo $*" && SHOW_INFO_DONE=true
		else jshinfo "Output will be cached.  Retrieve with: memo $*" && SHOW_INFO_DONE=true
		fi
	fi

	# These used to appear after the CKSUM generation.
	export CHECKDIR CHECKFILE REMEMOWHEN MEMOFILE AGEFILE
	# Strangely we do not need to export MEMO_IGNORE_DIR MEMO_IGNORE_EXITCODE if they were set by caller.

	## TODO: WE DO NOT WANT TO CALL rememo!
	## We prefer memo to be a standonly script, and for rememo to call us!

	## This may have been set but not exported.  We pass it on, since rememo actually uses it.  Perhaps we should just add it to the above exports.
	IKNOWIDONTHAVEATTY=$IKNOWIDONTHAVEATTY rememo "$@"
	## TODO CONSIDER: If we did . rememo "$@" here, maybe functions would get called :)  Although if we have done importshfn memo, then that might achieve the same.
else
	[ -n "$DEBUG" ] && debug "[memo] re-using memofile=\"$MEMOFILE\""
	cat "$MEMOFILE"
fi
EXITWITH="$?"

[ -n "$AGEFILE" ] && rm -f "$AGEFILE"

if [ -n "$MEMO_SHOW_INFO" ] && [ -z "$SHOW_INFO_DONE" ]
then

	if [ -f "$MEMOFILE" ]
	then
		# TMPF=`jgettmp`   ## make a temporary "now" file
		TMPF="/tmp/now.$USER"   ## use the same file always, don't bother deleting it
		touch "$TMPF"
		# echo "as of "`date -r "$MEMOFILE"`
		# echo "% $@"
		TIMEAGO=`datediff -files "$MEMOFILE" "$TMPF"`
		# echo "`cursecyan`\"$*\" cached $TIMEAGO ago, in file \"$MEMOFILE\"`cursenorm`" >&2
		[ -z "$MEMO_NOSHOW_REUSE" ] && jshinfo "\"$*\" cached $TIMEAGO ago, in file \"$MEMOFILE\"" >&2
		# jdeltmp "$TMPF"
	else
		: ## memo failed to produce a file; due to invalid command?
	fi

fi
SHOW_INFO_DONE=

[ "$EXITWITH" = 0 ]
