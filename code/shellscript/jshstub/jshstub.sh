#!/bin/sh

OKTOGO=true
GOTBYANOTHERSTUB=

SCRIPTFILE="$0"
## note not yet absolute path
SCRIPTNAME=`basename "$SCRIPTFILE"`

if test "$TOSOURCE"
then
	# echo "[ jshstub: Noticed joeybashource = $TOSOURCE ok ]" >&2
	if test ! "${TOSOURCE##/*}"
	then SCRIPTFILE="$TOSOURCE"
	else SCRIPTFILE="$JPATH/tools/$TOSOURCE"
	fi
	SCRIPTNAME=`basename "$SCRIPTFILE"`
	SCRIPT_WAS_SOURCED="(joeybashsourced) "
	unset TOSOURCE
fi

## TODO: need a better check than this! (would need absolute path at least)
# TOOLDIR="$JPATH/tools"
# if test ! "`dirname "$SCRIPTFILE"`" = "$TOOLDIR"
# then
	# echo "jshstub: Aborting because $SCRIPTFILE is not in \$JPATH/tools" >&2
	# exit 1
# fi

if test "$SCRIPTNAME" = jshstub
then
	echo "[ jshstub: Refusing to retrieve another copy of jshstub! ]" >&2
	OKTOGO=
fi

if test ! -L "$SCRIPTFILE"
then
	## If this script was sourced by name then $0 has filename but no path.  Try this path:
	if test -L "$JPATH/tools/$SCRIPTFILE"
	then
		SCRIPTFILE="$JPATH/tools/$SCRIPTFILE"
		## But of course this doesn't always work 'cos startj is often sourced with full path!
		SCRIPT_WAS_SOURCED="(sourced) "
	else
		echo "[ jshstub: $SCRIPTFILE is not a symlink! ]" >&2
		OKTOGO=true
		GOTBYANOTHERSTUB=true
	fi
fi

if test $OKTOGO
then

	## Block if another jshstub is getting the script (can happen eg. | highlight ... | highlight ...)
	## TODO: race condition
	LOCKFILE="$JPATH/tmp/$SCRIPTNAME.jshstub_lock"
	if test -f "$LOCKFILE"
	then
		echo "[ jshstub: Waiting for lock release on $LOCKFILE ]" >&2
		while true
		do
			## Check if lockfile has been cleared yet:
			if test ! -f "$LOCKFILE"
			then GOTBYANOTHERSTUB=true; break
			fi
			sleep 1
			## Timeout if lockfile is not cleared after 1 minute:
			touch -d "1 minute ago" "$LOCKFILE.compare"
			if test "$LOCKFILE.compare" -nt "$LOCKFILE"
			then
				# echo "[ jshstub: Timeout on $LOCKFILE.  Ploughing on... ]" >&2
				ls -l "$LOCKFILE" "$LOCKFILE.compare" >&2
				break
			fi
		done
	fi

	if test ! $GOTBYANOTHERSTUB
	then

		touch "$LOCKFILE"

		test "$JSH_STUB_NET_SOURCE" || export JSH_STUB_NET_SOURCE="http://hwi.ath.cx/jshstubtools/"

		if which wget 2>&1 > /dev/null
		then WGETCOM="wget -O -"
		else WGETCOM="lynx --source"
		fi

		rm -f "$SCRIPTFILE"

		# echo "[ jshstub: Received call $SCRIPT_WAS_SOURCED$SCRIPTNAME ($*) ]" >&2
		## When sourced in zsh, $WGETCOM was not being expanded as desired.
		eval $WGETCOM -q "$JSH_STUB_NET_SOURCE/$SCRIPTNAME" > "$SCRIPTFILE"

		if test "$?" = 0
		then
			echo "[ jshstub: Downloaded $SCRIPTNAME ok ]" >&2
			chmod a+x "$SCRIPTFILE"
		else
			echo "[ jshstub: Error: failed to retrieve http://hwi.ath.cx/jshstubtools/$SCRIPTNAME ]" >&2
			echo "[ jshstub: Replacing removed symlink, and stopping with false. ]" >&2
			rm -f "$SCRIPTFILE"
			ln -s "$JPATH/tools/jshstub" "$SCRIPTFILE"
			OKTOGO=
		fi

		rm -f "$LOCKFILE"

	fi

	if test $OKTOGO && test ! "$DONTEXEC"
	then

		# echo "[ jshstub: Calling . $SCRIPTFILE $* ]" >&2
		# echo >&2

		. "$SCRIPTFILE" "$@"

	else false
	fi

else false
fi
