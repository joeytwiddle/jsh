# jsh-ext-depends: dirname
# jsh-depends: jdeltmp jgettmp
# jsh-depends-ignore: jsh

## TODO: the other day, unfortunately, /tmp/jsh-joey was owned by and private to root.  This script tried to re-create it.  Did it then try to use it?!  This behaviour is bad.  It should just find an alternative.

if [ "$1" = -top ]
then

	## First usage: find a suitable top temp directory.

	if [ ! "$TOPTMP" ] || [ ! -w "$TOPTMP" ]
	then

		## Prevents second choice in list below from being /tmp in absence of JPATH, which can be bad if root chmod's it!
		if [ ! "$JPATH" ]
		then JPATH="/NOT/LIKELY"
		fi

		[ ! "$USER" ] && USER="$UID"
		for TOPTMP in "$TMPDIR" "/tmp/jsh-$USER" "$JPATH/tmp" "$HOME/tmp" "$PWD/.tmp" NO_DIR_WRITEABLE
		do

			if [ "$TOPTMP" ]
			then
				if [ -w "$TOPTMP" ]
				then break
				fi
				PARENT="`dirname \"$TOPTMP\"`"
				if [ -w "$PARENT" ]
				then
					# echo "Creating a temporary directory for jsh: $TOPTMP" >&2
					jshwarn "jgettmpdir: Creating a temporary directory for jsh: $TOPTMP"
					# mkdir "$TOPTMP" && break
					mkdir "$TOPTMP"
					## TODO: we should be do ( -d || -L (symlink) ), provided it will fail if symlink target dir is not writeable (ie. doesn't use perms of symlink itself)
					[ -d "$TOPTMP" ] && [ -w "$TOPTMP" ] && break
					jshwarn "jgettmpdir: but it isn't writeable by $JSHUSERNAME (uid=$UID)"
				fi
			fi

		done

		## Could be moved up into dir creation code, if people want to open up their tmpdirs!
		## This is safer for tmpdir data protection, but dangerous if user wanted TOPTMP to remain open (eg. /tmp if U R root!)
		chmod go-rwx $TOPTMP
		## Also, what's to say that we are neccessarily owner?!

	fi

	export TOPTMP

	[ "$DEBUG" ] && debug "export TOPTMP=$TOPTMP" || true ## || true ensures this script exits/returns 0 (because it is sometimes sourced, and its exit code is checked)!

	## Even better exit code:
	[ -d "$TOPTMP" ] && [ -w "$TOPTMP" ]

else

	## Second usage: allocate a tmpdir for an app to use temporarily.

	# Makes bash exit (with error code) if jgettmp fails.
	set -e
	TMP=`jgettmp "$@"`
	jdeltmp "$TMP"
	mkdir -p "$TMP"
	chmod go-rwx "$TMP"
	echo "$TMP"

fi
