# jsh-depends: jdeltmp jgettmp
# jsh-depends-ignore: jsh

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
					echo "Creating a temporary directory for jsh: $TOPTMP" >&2
					mkdir "$TOPTMP" && break
				fi
			fi

		done

		## Could be moved up into dir creation code, if people want to open up their tmpdirs!
		## This is safer for tmpdir data protection, but dangerous if user wanted TOPTMP to remain open (eg. /tmp if U R root!)
		chmod go-rwx $TOPTMP
		## Also, what's to say that we are neccessarily owner?!

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
