#!/bin/bash
# jsh-ext-depends-ignore: find

## We could be using a much shorter version:
# if [ "$TOPTMP" ]
# then
	# [ "$DEBUG" ] && jshinfo "jgettmpdir called when TOPTMP already known."
# else
	# export TOPTMP
	# TOPTMP=/tmp/jsh-"$USER"
	# mkdir -p "$TOPTMP"
	# chmod go-rwx "$TOPTMP"
	# ## Done
# fi

# jsh-ext-depends: dirname
# jsh-depends: jdeltmp jgettmp errorexit
# jsh-depends-ignore: jsh debug

## It would be quite nice to have a tmpdir at /dev/shm/something so that we can
## change the permissions of something.  But we really ensure scripts perform
## cleanup, or at least have some auto-cleaning.

## TODO: the other day, unfortunately, /tmp/jsh-joey was owned by and private
## to root.  This script tried to re-create it.  Did it then try to use it?!
## This behaviour is bad.  It should just find an alternative.

if [ "$1" = -top ]
then

	## First usage: find a suitable top temp directory.

	if [ ! "$TOPTMP" ] || [ ! -w "$TOPTMP" ] || [ ! -O "$TOPTMP" ]
	then

		## Prevents second choice in list below from being /tmp in absence of JPATH, which can be bad if root chmod's it!
		if [ ! "$JPATH" ]
		then JPATH="/NOT/LIKELY"
		fi

		# [ ! "$USER" ] && USER="$UID" ## we add uid, in case $USER is inaccurate (like $HOME often is)
		## $USER can be inaccurate (e.g. su instead of su -), so we always use $UID ## "/tmp/jsh-$USER" "/tmp/jsh-$UID" 
		## Ah no, USER was fine, the problem was that we had already exported TOPTMP, so we never got here to reset it! "/tmp/jsh-$USER.$UID" 
		[ "$USER" ] && JSHTMP=/tmp/jsh-"$USER"
		[ "$USER" ] || JSHTMP=/tmp/jsh-"$UID"

		## OK so we won't use TOPTMP, in case that was exported by a different user before we su-ed:
		for TOPTMP in "$TMPDIR" "$JSHTMP" "$HOME/.jshtmp" "$JPATH/tmp" "$HOME/tmp" "$PWD/.tmp" NO_DIR_WRITEABLE
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
					jshinfo "jgettmpdir: Creating a temporary directory for jsh: $TOPTMP"
					# mkdir "$TOPTMP" && break
					mkdir "$TOPTMP"
					## TODO: we should be do ( -d || -L (symlink) ), provided it will fail if symlink target dir is not writeable (ie. doesn't use perms of symlink itself)
					[ -d "$TOPTMP" ] && [ -w "$TOPTMP" ] && break
					jshwarn "jgettmpdir: but it isn't writeable by $JSHUSERNAME (uid=$UID)"
				fi
			fi

		done

		if [ "$TOPTMP" = NO_DIR_WRITEABLE ]
		then . errorexit "jgettmpdir could not find a writeable temp directory." ## this is quite harsh since jgettmpdir is sometimes sources; but OTOH most scripts assumes sourcing this script succeeded, and would continue with problems if it failed
		fi

		## Could be moved up into dir creation code, if people want to open up their tmpdirs!
		## This is safer for tmpdir data protection, but dangerous if user wanted TOPTMP to remain open (eg. /tmp if U R root!)
		##
		## On macOS,/var/folders/1t/nyrXXXX55bb_83tmbXXXXXXc0000gn/T/ already has these permissions, and trying to set them prints an error "changing permissions of 'XXXXX': Operation not permitted"
		if [ "$(uname)" = Darwin ]
		then chmod go-rwx "$TOPTMP" 2>/dev/null
		else chmod go-rwx "$TOPTMP"
		fi
		## Also, what's to say that we are neccessarily owner?!

	fi

	export TOPTMP

	[ "$DEBUG" ] && debug "[jgettmpdir] export TOPTMP=$TOPTMP" # || true ## || true ensures this script exits/returns 0 (because it is sometimes sourced, and its exit code is checked)!

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
