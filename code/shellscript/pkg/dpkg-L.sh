## Fast version of dpkg -L

if [ "$1" = -test ]
then
	shift
	SYS=`jgettmp dpkg_-L`
	HAK=`jgettmp dpkg-L`
	# dpkg -L "$@" | filesonly -inclinks | sort > $SYS
	time dpkg-L  "$@" | sort > $HAK
	time dpkg -L "$@" | sort > $SYS
	vimdiff $SYS $HAK
	jdeltmp $SYS $HAK
	exit
fi

PACKAGENAME="$1"
BASENAME=/var/lib/dpkg/info/$PACKAGENAME

## Reads only one file, but doesn't cksum all.
# cat $BASENAME.md5sums |
# dropcols 1 |
# sed 's+^+/+'

(
	cat $BASENAME.list
	[ -f $BASENAME.conffiles ] && cat $BASENAME.conffiles
) # | removeduplicatelines -adj
