# jsh-depends-ignore: jsh
# jsh-depends: jdeltmp jgettmp
if test "$1" = -top
then

	## First usage: find a suitable top temp directory.

	[ "$TMPDIR" ] && TOPTMP="$TMPDIR" || TOPTMP="/tmp/jsh-$USER"

	# if test ! -w $TOPTMP || ( test "$JTMPLOCAL" && test -w . )
	# then
	# # Note we don't use $PWD because might break * below
	# TOPTMP="/tmp"
	# fi

	if [ ! -w "$TOPTMP" ]
	then
		TOPTMP="/tmp/jsh-$USER"
		## If it exists but isn't writeable:
		while [ -e $TOPTMP ] && [ ! -w $TOPTMP ]
		do TOPTMP="$TOPTMP"_
		done
		if [ ! -e $TOPTMP ]
		then
			echo "Creating a temporary directory for jsh: $TOPTMP" >&2
			mkdir -p $TOPTMP
		fi
		chmod go-rwx $TOPTMP
	fi

	export TOPTMP

else

	## Second usage: allocate a tmpdir for an app to use temporarily.

	# Makes bash exit if jgettmp fails.
	set -e
	TMP=`jgettmp "$@"`
	jdeltmp "$TMP"
	mkdir -p "$TMP"
	chmod go-rwx "$TMP"
	echo "$TMP"

fi
