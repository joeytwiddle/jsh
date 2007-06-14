# jsh-depends: cursemagenta cursenorm memo removeduplicatelines takecols jdeltmp jgettmp drop error
# this-script-does-not-depend-on-jsh: arguments pkgversions
# jsh-ext-depends: sed apt-cache apt-get dpkg column
# jsh-ext-depends-ignore: find env from file update

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

## Cached data need only be refreshed if sources have changed, or been updated:
MEMOCOM="memo -f /etc/apt/sources.list -d /var/lib/apt"
## if we are interested in installed packages, the cached data must be refreshed if installed packages have been changed
if [ "$INSTALLED" ]
then MEMOCOM="$MEMOCOM -f /var/lib/dpkg/status"
fi
# DPKGMEMOCOM="memo -f /var/lib/dpkg/status"
DPKGMEMOCOM="$MEMOCOM"

if [ "$1" = --help ]
then

cat << ! | more

Usage:

  apt-list [ <option>s... ] ( all | sources | distros | from ... | pkg ... )

Commands:

  apt-list all                  : list all available packages & sources
  apt-list sources              : list repositories which we draw from
  apt-list distros              : list stability status
  apt-list from <source/distro> : list packages in source or distro
  apt-list pkg <package>        : list available versions of package

Options:

  -installed           : trims results to show installed packages only
  --source-list <file> : use alternative sources list

Note:

  apt-list is responsive to the sources in your current sources.list,
  so if like me you apt-get update using a broader sources file, you
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
exit 1

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

    export LIST=`jgettmp apt-list`
    export INSTALLED=
    apt-list all $SOURCE_LIST | tr -s ' ' > $LIST

    echo "`cursemagenta`apt-list: building installed cache subset, u may get annoyed now...`cursenorm`" >&2

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

    jdeltmp $LIST

  else

    echo "`cursemagenta`apt-list: building cache from apt-cache$APT_EXTRA_ARGS dump, please be patient...`cursenorm`" >&2
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

		echo "[TODO] apt-list called with no args: should show help."

else

  error "[apt-list] Do not understand arguments: $*"
  exit 2

fi
