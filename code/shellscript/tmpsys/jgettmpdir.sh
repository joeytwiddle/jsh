# jsh-depends: jdeltmp jgettmp
if test "$1" = -top
then

	## First usage: find a suitable top temp directory.

	test "$TMPDIR" && TOPTMP="$TMPDIR" || TOPTMP="$JPATH/tmp"

	# if test ! -w $TOPTMP || ( test "$JTMPLOCAL" && test -w . )
	# then
	# # Note we don't use $PWD because might break * below
	# TOPTMP="/tmp"
	# fi

	if test ! -w "$TOPTMP"
	then
		TOPTMP="/tmp/jsh-tempdir-for-$USER"
		## If it exists but isn't writeable:
		while test -e $TOPTMP && test ! -w $TOPTMP
		do TOPTMP="$TOPTMP"_
		done
		if test ! -e $TOPTMP
		then mkdir -p $TOPTMP
		     echo "Created a temporary directory for you: $TOPTMP" >&2
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
