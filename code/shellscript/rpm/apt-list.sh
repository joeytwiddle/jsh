cd / # for memoing

# if [ "$1" = -refresh ]
# then export REMEMO=true; shift
# fi

## Automatically memo everything (certainly simplifies stuff!):
# if [ ! "$1" = -memoing ]
# then memo -d /var/lib/apt -f /var/lib/dpkg/status apt-list-all -memoing "$@"; exit
# fi

## TODO: option to regen caches (eg. at end of your apt-get-update cronjob)
# apt-get-list $SOURCE_LIST > /dev/null
# apt-get-list -installed $SOURCE_LIST > /dev/null

while true
do
  if [ "$1" = --source-list ]
  then
    SOURCE_LIST="--source-list $2" ## for passing around and memoing
    APT_EXTRA_ARGS="$APT_EXTRA_ARGS --option Dir::Etc::sourcelist=$2"
    shift; shift
  elif [ "$1" = -installed ]
  then
    INSTALLED="-installed" ## for passing around and memoing, and acts as flag
    shift
  else break
  fi
done

## cached data must be refreshed if sources have been updated:
MEMOCOM="memo -d /var/lib/apt"
## if we are interested in installed packages, the cached data must be refreshed if installed packages have been changed
if [ "$INSTALLED" ]
then MEMOCOM="$MEMOCOM -f /var/lib/dpkg/status"
fi
# DPKGMEMOCOM="memo -f /var/lib/dpkg/status"
DPKGMEMOCOM="$MEMOCOM"

if [ "$1" = --help ]
then

  echo
  echo "Usage:"
  echo
  echo "  apt-list-all                   : list all available packages & sources"
  echo "  apt-list-all sources           : list repositories which we draw from"
  echo "  apt-list-all levels            : list stability levels"
  echo "  apt-list-all in <source/level> : list packages in source or level"
  echo "  apt-list-all pkg <package>     : list available versions of package"
  echo "                                   (see also pkgversions)"
  echo
  echo "Options:"
  echo
  echo "  -installed           : trims results to show installed packages only"
  # echo "  -refresh  : refresh cache (use when you have new updates)"
  echo "  --source-list <file> : use alternative sources list"
  echo
  echo "Note:"
  echo
  echo "  apt-list-all is responsive to the sources in your current sources.list,"
  echo "  but if like me you apt-get update using a broader sources file, you"
  echo "  should use the --source-list option."
  echo
  exit 1

  ## There is also the command apt-list-all generate, but that is meant for internal use only.

elif [ "$1" = in ]
then

  SRC="$2"
  shift; shift
  $MEMOCOM apt-list-all $INSTALLED $SOURCE_LIST "$@" | grep " \<$SRC\>" |
  column -t

elif [ "$1" = pkg ]
then

  PKG="$2"
  shift; shift
  $MEMOCOM apt-list-all $INSTALLED $SOURCE_LIST "$@" | grep "^$PKG " |
  column -t

elif [ "$1" = sources ]
then

  $MEMOCOM "apt-list-all $INSTALLED $SOURCE_LIST | takecols 4 | drop 1 | removeduplicatelines"

elif [ "$1" = levels ]
then

  $MEMOCOM "apt-list-all $INSTALLED $SOURCE_LIST | takecols 3 | drop 1 | removeduplicatelines"

elif [ "$1" = generate ]
then

  if [ "$INSTALLED" ]
  then

    ## Used to build a big regexp for grep but it was too slow.

    LIST=`jgettmp apt-list-all`
    apt-list-all $SOURCE_LIST | tr -s ' ' > $LIST

    echo "`cursemagenta`apt-list-all: building installed cache from main cache, please be patient...`cursenorm`" >&2

    ## TODO: this memo file is too large, and we only need cache the output
    # $DPKGMEMOCOM "env COLUMNS=480 dpkg -l | takecols 2 3 | drop 5" |
    env COLUMNS=480 dpkg -l | takecols 2 3 | drop 5 |
    while read PKGNAME PKGVER REST
    do
      [ "$REST" ] && error "Unexpected data: $REST"
      # echo "seeking $PKGNAME $PKGVER" >&2
      cat $LIST | grep "^$PKGNAME \([0-9]*:\|\)$PKGVER" || # && error "Got $PKGNAME $PKGVER ok"
      # grep "^$PKGNAME $PKGVER" $LIST # && ( echo "found $PKGNAME ok" >&2 ) ||
      error "Could not find $PKGNAME ver $PKGVER (which dpkg reports installed) in cache!"
    done |
    column -t

    jdeltmp $LIST

  else

    echo "`cursemagenta`apt-list-all: building cache from apt-cache$APT_EXTRA_ARGS dump, please be patient...`cursenorm`" >&2
    (
      echo "PACKAGE	VERSION	STATUS	SOURCE"
      $MEMOCOM apt-cache $APT_EXTRA_ARGS dump |
      grep "^\(Package\| Version\|[ ]*File\): " |
      # This sed fails for non-traditional archives (lacking dist/ dir):
      sed "s|File: .*/\([^_]*\).*dists_\([^_]*\).*|File: \1 \2|" |
      sed "s|File: /var/lib/dpkg/status|File: local_only unknown|" |
      sed "s|File: /var/lib/apt/lists/\(.*\)_\._Packages|File: \1 unknown|" |
      sed "s|File: /var/lib/apt/lists/\(.*\)_Packages|File: \1 unknown|" |
      awk ' {
        if ( $1 == "Package:" )
          { PACK=$2 }
        if ( $1 == "Version:" )
          { VER=$2 }
        if ( $1 == "File:" )
          { PROVIDER=$2 ; STAT=$3; print PACK "\t" VER "\t" STAT "\t" PROVIDER }
      } ' |
      cat
    ) |
    column -t

  fi

elif [ "$1" = "" ]
then

    $MEMOCOM apt-list-all $INSTALLED $SOURCE_LIST generate

else

  echo "apt-list-all: Do not understand arguments: $*"
  exit 2

fi
