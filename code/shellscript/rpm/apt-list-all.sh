# Lists all versions of packages available for download.

cd / # for memoing

# if [ "$1" = -refresh ]
# then export REMEMO=true; shift
# fi

# if [ ! "$1" = -memoing ]
# then memo apt-list-all -memoing "$@"; exit
# fi

if [ "$1" = --source-list ]
then
  SOURCE_LIST="--source-list $2" ## for passing around and memoing
  APT_EXTRA_ARGS="$APT_EXTRA_ARGS --option Dir::Etc::sourcelist=$2"
  shift; shift
fi

MEMOCOM='memo -d /var/lib/apt'
# DPKGMEMOCOM='memo -d /var/lib/dpkg'
DPKGMEMOCOM='memo -f /var/lib/dpkg/status'

if [ "$1" = --help ]
then

  echo
  echo "Usage:"
  echo
  echo "  apt-list-all [ installed ]            : list all available packages & sources"
  echo "  apt-list-all sources [ installed ]    : list repositories which we draw from"
  echo "  apt-list-all levels [ installed ]     : list stability levels"
  echo "  apt-list-all in <source/level> [i]    : list packages which match (fuzzy)"
  echo "  apt-list-all with <package_name>  [i] : list available versions of package"
  echo "                                          (see also pkgversions)"
  echo
  echo "Options:"
  echo
  echo "  installed : as last argument, trims results to show installed packages only."
  # echo "  -refresh  : as first argument, refresh cache (use when you have new updates)"
  echo "  --source-list <file> : as first argument, uses alternative sources list."
  echo
  echo "Note:"
  echo
  echo "  apt-list-all is responsive to the sources in your current sources.list,"
  echo "  which are not necessarily all the sources you have info on, (eg. if like me,"
  echo "  you apt-get update using a broader sources file.)"
  echo
  exit 1

elif [ "$1" = in ]
then

  SRC="$2"
  shift; shift
  $MEMOCOM apt-list-all $SOURCE_LIST "$@" | grep "$SRC" |
  column -t

elif [ "$1" = with ]
then

  PKG="$2"
  shift; shift
  $MEMOCOM apt-list-all $SOURCE_LIST "$@" | grep "^$PKG " |
  column -t

elif [ "$1" = sources ]
then

  if [ "$2" = installed ]
  then $MEMOCOM apt-list-all $SOURCE_LIST installed | takecols 4 | drop 1 | removeduplicatelines
  else apt-list-all $SOURCE_LIST | takecols 4 | drop 1 | removeduplicatelines
  fi

elif [ "$1" = levels ]
then

  if [ "$2" = installed ]
  then $MEMOCOM apt-list-all $SOURCE_LIST installed | takecols 3 | drop 1 | removeduplicatelines
  else apt-list-all $SOURCE_LIST | takecols 3 | drop 1 | removeduplicatelines
  fi

elif [ "$1" = installed ]
then

  echo "`curseyellow`apt-list-all: building installed cache from main cache, please be patient...`cursenorm`" >&2
  LIST=`jgettmp apt-list-all`
  apt-list-all $SOURCE_LIST > $LIST

  $DPKGMEMOCOM "env COLUMNS=480 dpkg -l | takecols 2 | drop 5" |

  while read PKGNAME
  do

    grep "^$PKGNAME " $LIST ||
    error "Could not find $PKGNAME (which dpkg reports installed) in cache!"

  done |

  column -t

  jdeltmp $LIST

elif [ "$1" = memoing ]
then

  echo "`curseyellow`apt-list-all: building cache from apt-cache$APT_EXTRA_ARGS dump, please be patient...`cursenorm`" >&2
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

elif [ "$1" = "" ]
then

  $MEMOCOM apt-list-all $SOURCE_LIST memoing

else

  echo "apt-list-all: Do not understand arguments: $*"
  exit 2

fi
