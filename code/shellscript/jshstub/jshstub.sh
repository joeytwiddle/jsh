#!/bin/sh

## Hooray!  By aliasing . and source to joeybashsource, we can intercept sources and deal with them approriately

## TODO: locking of jshstub's if another jshstub is already trying to retrieve the link

## TODO: if we identify that this call was a source, shouldn't we source the target?

## Goddammit I have that classic problem when bash sources us!

## For bash: hmmm still working on it
# echo "[[ jshstub: $SCRIPTNAME ( $_ | $0 | $# | $* | $FUNCNAME ) =$TOSOURCE= ]]" >&2
# echo "\$\_ = >$_<" >&2
# echo "\$\0 = >$0<" >&2
# echo "\$\# = >$#<" >&2
# echo "\$\* = >$*<" >&2
# echo "\$\FUNCNAME = >$FUNCNAME<" >&2
# set > /tmp/set.out >&2
# env > /tmp/env.out >&2
# history > /tmp/history.out >&2

OKTOGO=true
GOTBYANOTHERSTUB=

SCRIPTFILE="$0"
## note not yet absolute path
SCRIPTNAME=`basename "$SCRIPTFILE"`

#### For bash experiment:
# test $SCRIPTNAME = bash &&
# echo "AAA = $TOSOURCE" | tee -a /tmp/jshstub.log >&2 &&
# echo "SCRIPTNAME=$SCRIPTNAME TOSOURCE=$TOSOURCE" >&2
# if test "$SCRIPTNAME" = bash && test "$TOSOURCE"
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
		# echo "[ jshstub: (Looks like this script was sourced) ]" >&2
	else
		## It seems we have problems: when the final call is made, sh caches this script and re-runs it.
		## We end up here, but the caching continues if we try again.
		## This caching problem still occurs occasionally with zsh
		# echo "[ jshstub: Strangely $SCRIPTFILE is not a symlink, trying to run it again... ]" >&2
		# "$SCRIPTFILE" "$@"
		echo "[ jshstub: $SCRIPTFILE is not a symlink! ]" >&2
		OKTOGO=true
		GOTBYANOTHERSTUB=true
	fi
fi

if test $OKTOGO
then

	## Block if another jshstub is getting the script (can happen eg. | highlight ... | highlight ...)
	## TOOD: race condition
	LOCKFILE="$JPATH/tmp/$SCRIPTNAME.jshstub_lock"
	if test -f "$LOCKFILE"
	then
		echo "[ jshstub: Waiting for lock release on $LOCKFILE ]" >&2
		while true
		do
			## Check if lockfile has been cleared yet
			if test ! -f "$LOCKFILE"
			then GOTBYANOTHERSTUB=true; break
			fi
			sleep 1
			## Timeout if lockfile is not cleared after 1 minute
			touch -d "1 minute ago" "$LOCKFILE.compare"
			if test "$LOCKFILE.compare" -nt "$LOCKFILE"
			then
				echo "[ jshstub: Timeout on $LOCKFILE.  Ploughing on... ]" >&2
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

		echo "[ jshstub: Got request for $SCRIPT_WAS_SOURCED$SCRIPTNAME $* ]" >&2
		## When sourced in zsh, $WGETCOM was not being expanded as desired.
		eval $WGETCOM -q "$JSH_STUB_NET_SOURCE/$SCRIPTNAME" > "$SCRIPTFILE"

		if test "$?" = 0
		then
			echo "[ jshstub: Downloaded $SCRIPTNAME ok. ]" >&2
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

	if test $OKTOGO # && test ! "$DONTEXEC"
	then

		echo "[ jshstub: Running: $SCRIPTFILE $* ]" >&2
		echo >&2
		## For bash experiment (doesn't work!):
		hash -r

		## Really we want to source it anyway (no point starting another sub-sh, script would have run in this one had it been there!)
		# if test "$SCRIPT_WAS_SOURCED"
		# then
			# test "$TOSOURCE" &&
			# export TOSOURCE="$SCRIPTFILE"
			# echo "ZZZ = $TOSOURCE" | tee -a /tmp/jshstub.log >&2
			# . $JPATH/tools/joeybashsource "$SCRIPTFILE" "$@"
			# echo "ZZZfinished = $SCRIPTFILE $TOSOURCE" | tee -a /tmp/jshstub.log >&2
			# source "$SCRIPTFILE" "$@"
			. "$SCRIPTFILE" "$@"
		# else
			# "$SCRIPTFILE" "$@"
		# fi

	else false
	fi

else false
fi
