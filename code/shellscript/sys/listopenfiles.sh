#!/bin/sh
## Still getting duplicates, if process is reading file with multiple threads/PIDs:
## Use listopenfiles <whatever> | dropcols 2 | removeduplicatelines
## Make this an option defaulting to on (could call it "merge threads")

## NOTE: Add `-d 0-2` to lsof to exclude lots of files (including shared libraries).  But maybe it excludes too much.

if [ "$1" = --help ]
then cat << !

listopenfiles [ -allthreads | -mergethreads | -mergeprocesses ] [ <start_of_process_name> ] [ <lsof_options> ]

  will list all files the process currently has opened for reading or writing.
  <start_of_process_name> is a regexp, but don't try to match more than 8 chars!
  (TODO: fix this with lsof's +c <cols> option)
  If no regexp is given, or "", or ., then all processes are listed, which may
  take longer.

  -allthreads will show every file access by every thread, it is fast but long.

  -mergethreads will hide duplicate file accesses from the same process (PID).
    This is the default.

  -mergeprocesses will hide duplicates files accesses from the same
    application, by removing the PIDs from the output.

  NOTE: The fourth column has flags describing the type of access the thread is
  making, e.g. u/ur/uw.  We may want to drop that column for mergethreads and
  mergeprocesses.

  Try: export ENABLE_COLOUR=true

  To list normal files opened for reading, excluding libraries:

    listopenfiles chrome | grep "\<REG\>" | grep -v "\<mem\>"

  See also: listfilesopenby <part_of_process_name> which is much faster

!
exit 1
fi

##  If a process has more than one file open, its PID will be listed more than once.
##  (We could default to showing only the first PID in each otherwise identical group.)
##  (Idk what that meant! :p We could drop all the extra info, and list each file only once,
##    but with a comma-separated list of all the PIDs :)
##  (listopenfiles is a friendly wrapper for lsof, which strips some but not all of lsof's
##    listings, and currently still retains some of lsof's meta-info about each access,
##    which it might be better to strip.)

MERGE_THREADS=true ; MERGE_PROCESSES=
if [ "$1" = -allthreads ]
then shift; MERGE_PROCESSES= ; MERGE_THREADS=
fi
if [ "$1" = -mergethreads ]
then shift; MERGE_THREADS=true ; MERGE_PROCESSES=
fi
if [ "$1" = -mergeprocesses ]
then shift; MERGE_THREADS=true ; MERGE_PROCESSES=true
fi

column5not () {
	WORD="$1"
	FIELD="[^ 	]*"
	GAP="[ 	]*"
	grep -v "^$FIELD$GAP$FIELD$GAP$FIELD$GAP$FIELD$GAP$WORD$GAP"
}

column4not () {
	WORD="$1"
	FIELD="[^ 	]*"
	GAP="[ 	]*"
	grep -v "^$FIELD$GAP$FIELD$GAP$FIELD$GAP$WORD$GAP"
}

column5regexp () {
	WORD="$1"
	FIELD="[^ 	]*"
	GAP="[ 	]*"
	echo "^$FIELD$GAP$FIELD$GAP$FIELD$GAP$FIELD$GAP$WORD$GAP"
}

column5is () {
	REGEXP=`column5regexp "$@"`
	grep "$REGEXP"
}

column4regexp () {
	WORD="$1"
	FIELD="[^ 	]*"
	GAP="[ 	]*"
	echo "^$FIELD$GAP$FIELD$GAP$FIELD$GAP$WORD$GAP"
}

column4color () {
	REGEXP=`column4regexp "$1"`
	sed "s+$REGEXP.*+$2\0`cursenorm`+"
}

if [ "$1" ]
then
	PROCESS_NAME="$1"
	shift
fi

## Find the lsof executable:
if [ ! -x "$LSOF" ]
then
	LSOF=`which lsof 2>/dev/null`
	if [ ! -x "$LSOF" ]
	then
		LSOF=/usr/sbin/lsof
		if [ ! -x "$LSOF" ]
		then
			error "Couldn't find lsof."
			exit 1
		fi
	fi
fi

## Stuff we (could) disable:
## -n : don't convert IP address to hostname
## -S 2 : spend at max 2 seconds in kernel calls
## -l : don't convert login IDs to login names
## -P : don't convert port numbers to service names
## -V : for debugging (lists failures)
## -o : because we are more interested in offset than filesize XXX wanted to use this but lsof complained

"$LSOF" -n -S 2 -V "$@" |
grep "^$PROCESS_NAME" |
# grep "^[^ ]*[ ]*[^ ]*[ ]*[^ ]*[ ]*[^ ]*r " | ## Only files opened for reading
# grep "\<REG\>" |
# grep "^[^ ]*[ ]*[^ ]*[ ]*[^ ]*[ ]*[^ ]*[ru] " | column5not "TCP" | column5not "sock" | ## Only files opened for reading
# column4not "\(txt\|mem\)" |
# column5not "unix" |
# column5not "IPv4" |
# column5not "CHR" | ## Strip out pipes (or is it libraries?!)
# column5not "FIFO" | ## Strips fifos
# # column5is REG |
# column5is "REG" |
# grep -v "/lib/" | ## Because libraries still crop up despite above (for vim at least)

## The output may contain multiple entries for the same file and app, if:
##   - it is opened by multiple PIDs of the same application
## or
##   - it is opened by multiple threads of the same application
## so here we perform merging of redundant data.
if [ "$MERGE_THREADS" ]
then
  dropcols 7 8 |
  if [ "$MERGE_PROCESSES" ]
  then dropcols 2
  else cat
  fi |
  removeduplicatelines |
  columnise
else cat
fi |

## The following hide some non-files, and also unwanted stuff opened during: jwatch listopenfiles
grep -E -v "(^(lsof|pool) |/new-listopenfiles\.| pipe$)" |

if [ "$ENABLE_COLOUR" ]
then
	column4color "[0123456789]*r" "`cursegreen`" |
	column4color "[0123456789]*w" "`cursered``cursebold`" |
	column4color "[0123456789]*u" "`curseyellow`"
else
	cat
fi

