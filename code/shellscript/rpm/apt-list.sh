# Lists all versions of packages available for download.

cd / # for memoing

if [ "$1" = -refresh ]
then export REMEMO=true; shift
fi

# if [ ! "$1" = -memoing ]
# then memo apt-list-all -memoing "$@"; exit
# fi

MEMOCOM='memo -d /var/lib/apt'
# DPKGMEMOCOM='memo -d /var/lib/dpkg'
DPKGMEMOCOM='memo -f /var/lib/dpkg/status'

if [ "$1" = --help ]
then

  echo "Usage:"
  echo "  apt-list-all [ installed ]            : list all available packages"
  echo "  apt-list-all sources [ installed ]    : list repositories which we draw from"
  echo "  apt-list-all in <repository_name> [i] : list packages in given repository (fuzzy)"
  echo "  apt-list-all with <package_name>  [i] : list available versions of package"
  echo "Options:"
  echo "  installed : trims results to installed packages rather than all available."
  echo "  -refresh  : as first argument, refresh cache (use when you have new updates)"
  echo "Note:"
  echo "  apt-list-all is responsive to the sources in your current sources.list,"
  echo "  which are not necessarily all the sources you have info on, (eg. if like me,"
  echo "  you apt-get update using a broader sources file.)"
  exit 1

elif [ "$1" = in ]
then

  SRC="$2"
  shift; shift
  $MEMOCOM apt-list-all "$@" | grep "$SRC" |
  column -t

elif [ "$1" = with ]
then

  PKG="$2"
  shift; shift
  $MEMOCOM apt-list-all "$@" | grep "^$PKG " |
  column -t

elif [ "$1" = sources ]
then

  if [ "$2" = installed ]
  then $MEMOCOM apt-list-all installed | takecols 3 | removeduplicatelines
  else $MEMOCOM apt-list-all | takecols 3 | removeduplicatelines
  fi

elif [ "$1" = installed ]
then

  LIST=`jgettmp apt-list-all`
  apt-list-all > $LIST

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

  echo "apt-list-all: building cache from apt-cache dump, please be patient..." >&2
  (
    echo "PACKAGE	VERSION	STATUS	SOURCE"
    $MEMOCOM apt-cache dump |
    grep "^\(Package\| Version\|[ ]*File\): " |
    # This sed fails for non-traditional archives (lacking dist/ dir):
    sed "s|File: .*/\([^_]*\).*dists_\([^_]*\).*|File: \1 \2|" |
    sed "s|File: /var/lib/dpkg/status|File: local_only unknown|" |
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

  $MEMOCOM apt-list-all memoing

else

  echo "apt-list-all: Do not understand arguments: $*"
  exit 2

fi
