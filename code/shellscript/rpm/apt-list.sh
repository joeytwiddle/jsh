#!/bin/sh
# jsh-depends: cursemagenta cursenorm memo removeduplicatelines takecols jdeltmp jgettmp drop error
# jsh-depends-ignore: arguments pkgversions
# jsh-ext-depends: sed apt-cache apt-get dpkg column
# jsh-ext-depends-ignore: find env from file update

## BUG TODO: apt-list -all sometimes disagrees with dpkg -l, due to package numbering
## e.g.:
##      dpkg -l | takecols 2 3 > /tmp/1
##      apt-list -installed pkg ".*"  | takecols 1 2 > /tmp/2
##      vimdiff /tmp/[12]
## gives:
##      analog 5.32-14   vs   analog 2:5.32-14
## If the extra number comes at the start, apt-list has one entry, without the extra number.
##      apache-common 1.3.34-4   vs   apache-common 1.3.34-4   and   apache-common 1.3.34-4.1
## If the extra number comes at the end, apt-list usually has two entries, one with and one without the extra number.  (Maybe this case is NOT actually an error!)

## TODO: "distros" is probably not the correct terminology, and should be renamed throughout.  Maybe "levels"?

## TODO: Move the help to the top, so the flow becomes easier to read.

## DONE: rename apt-list
## TODO: make "apt-list" return help, and use "apt-list generate" to make the big list

## CONSIDER: add each package's group as an additional column

cd / # for memoing

# if [ "$1" = -refresh ]
# then export REMEMO=true; shift
# fi

## Automatically memo everything (certainly simplifies stuff!):
# if [ ! "$1" = -memoing ]
# then memo -d /var/lib/apt -f /var/lib/dpkg/status apt-list -memoing "$@"; exit
# fi

## TODO: option to regen caches (eg. at end of your apt-get-update cronjob)
# apt-get-list $SOURCE_LIST > /dev/null
# apt-get-list -installed $SOURCE_LIST > /dev/null

# echo "$0 $*" >&2

## Cached data need only be refreshed if sources have changed, or been updated:
MEMOCOM="memo -f /etc/apt/sources.list -d /var/lib/apt"

## I don't like this too much!
while true
do
  if [ "$1" = --source-list ]
  then
    SOURCE_LIST="--source-list $2" ## for passing around and memoing
    APT_EXTRA_ARGS="$APT_EXTRA_ARGS --option Dir::Etc::sourcelist=$2"
    MEMOCOM="memo -f \$2\ -d /var/lib/apt"
    shift; shift
  elif [ "$1" = -installed ]
  then
    INSTALLED="-installed" ## for passing around and memoing, and acts as flag
    shift
  else break
  fi
done

## if we are interested in installed packages, the cached data must be refreshed if installed packages have been changed
if [ "$INSTALLED" ]
then MEMOCOM="$MEMOCOM -f /var/lib/dpkg/status"
fi
# DPKGMEMOCOM="memo -f /var/lib/dpkg/status"
DPKGMEMOCOM="$MEMOCOM"

if [ "$1" = --help ]
then

cat << !

Usage:

  apt-list [ <option>s... ] ( all | sources | distros | from ... | pkg ... )

Commands:

  apt-list all                  : list all available packages & sources
  apt-list sources              : list repositories which we draw from
  apt-list distros              : list stability status
  apt-list from <source/distro> : list packages in source or distro
  apt-list pkg <package>        : list available versions of package

  apt-list is an efficient way to make repeated queries about your apt
  database.  Although the first query may be slow, subsequent queries
  should be much faster than using apt-cache or dpkg.

  The <source/distro> and <package> arguments are regular expressions.

Options:

  -installed           : trims results to show installed packages only
  --source-list <file> : use alternative sources.list file

Note:

  apt-list is responsive to the sources in your current sources.list.
  If you like to run apt-get update using a broader .sources file, you
  should use the --source-list option to specify it.

Examples:

  To see a list of available sources:
     apt-list sources

  To see a list of packages installed from one source:
     apt-list -installed from marillat.free.fr

  To see where different versions of libc6 come from:
     apt-list pkg libc6

!
# echo "  -refresh  : refresh cache (use when you have new updates)"
# (see also pkgversions) [it uses apt-cache directly, and tells you which one is currently installed. ]
## There is also the command apt-list generate, but that is meant for internal use only.

## Since we are taking some time anyway, pre-generate (aka show summary, aka pre-load cache, aka test generation speed):
echo "Auto-querying now... (Ctrl+C to abort)"
echo "Sources: "`apt-list sources` # | tr '\n' " " ; echo
echo "Distros: "`apt-list distros` # | tr '\n' " " ; echo
echo "Packages: "`apt-list all | wc -l`
echo "Installed: "`apt-list -installed all | wc -l`
echo

exit 0

## TODO: "apt-list pkg" might accidentally be used instead of "apt-list all", so it should do that :P

elif [ "$1" = from ]
then

  SRC="$2"
  shift; shift
  $MEMOCOM apt-list $INSTALLED $SOURCE_LIST all "$@" | grep " \<$SRC\>" |
  column -t

elif [ "$1" = pkg ]
then

  PKG="$2"
  shift; shift
  $MEMOCOM apt-list $INSTALLED $SOURCE_LIST "$@" all | grep "^$PKG " |
  column -t

elif [ "$1" = sources ]
then

  $MEMOCOM eval "$MEMOCOM apt-list $INSTALLED $SOURCE_LIST all | takecols 4 | drop 1 | removeduplicatelines"

elif [ "$1" = distros ]
then

  $MEMOCOM eval "apt-list $INSTALLED $SOURCE_LIST all | takecols 3 | drop 1 | removeduplicatelines"

elif [ "$1" = all ]
then

    $MEMOCOM apt-list $INSTALLED $SOURCE_LIST generate

elif [ "$1" = generate ]
# elif [ "$1" = all ]
# elif [ "$1" = all ] || [ "$1" = generate ]
then

  if [ "$INSTALLED" ]
  then

    ## Used to build a big regexp for grep but it was too slow.

    ## I don't like this!
    export LIST=`jgettmp apt-list`
    export INSTALLED=
    apt-list all $SOURCE_LIST | tr -s ' ' > $LIST ## Why do we put it into a list, when "apt-list all ..." caches its output anyway?!

    echo "`cursemagenta`[apt-list] Building installed cache subset, u may get annoyed now...`cursenorm`" >&2

    ## This memo file is too large, and we cache the output anyway!
    # $DPKGMEMOCOM "env COLUMNS=480 dpkg -l | takecols 2 3 | drop 5" |
    env COLUMNS=480 dpkg -l | takecols 2 3 | drop 5 |
		catwithprogress |
    while read PKGNAME PKGVER REST
    do
      [ "$REST" ] && error "Unexpected data: $REST"
      # echo "seeking >$PKGNAME $PKGVER<" >&2
      cat $LIST | grep "^$PKGNAME \([0-9]*:\|\)$PKGVER" || # && error "Got $PKGNAME $PKGVER ok"
      # grep "^$PKGNAME $PKGVER" $LIST # && ( echo "found $PKGNAME ok" >&2 ) ||
      error "Could not find $PKGNAME ver $PKGVER (which dpkg reports installed) in cache $LIST !"
    done |
    column -t
    echo "[`cursemagenta`apt-list] Cache built.`cursenorm`" >&2

    jdeltmp $LIST

  else

    echo "`cursemagenta`[apt-list] Building cache from apt-cache$APT_EXTRA_ARGS dump, please be patient...`cursenorm`" >&2
    (
      echo "PACKAGE	VERSION	DISTRO	SOURCE"
      ## This memo file is too large, and we cache the output anyway!
      apt-cache $APT_EXTRA_ARGS dump |
      catwithprogress |
      grep "^\(Package\| Version\|[ ]*File\): " |
      # This sed fails for non-traditional archives (lacking dist/ dir):
      sed "s|File: .*/\([^_]*\).*dists_\([^_]*\).*|File: \1 \2|" |
      sed "s|File: /var/lib/dpkg/status|File: no_source unknown|" |
      sed "s|File: /var/lib/apt/lists/\(.*\)_\._Packages|File: \1 unknown|" |
      sed "s|File: /var/lib/apt/lists/\(.*\)_Packages|File: \1 unknown|" |
      awk ' {
        if ( $1 == "Package:" )
          { PACK=$2 }
        if ( $1 == "Version:" )
          { VER=$2 } ## BUG TODO: I think this might miss the subversion (e.g. -3)
        if ( $1 == "File:" )
          { PROVIDER=$2 ; STAT=$3; print PACK "\t" VER "\t" STAT "\t" PROVIDER }
      } ' |
      ## Some systems start listing packages multiple times, I don't know why.
      ## We simply trim them here.
      removeduplicatelines | sort
    ) |
    column -t

  fi

elif [ "$1" = "" ]
then

  # echo "[TODO] apt-list called with no args: should show help."
  apt-list --help
  exit

else

  error "[apt-list] Do not understand arguments: $*"
  exit 2

fi
