## Get a script's dependencies

## Get a script's dependency data
## Generate a script's dependency data
## Compare and add new dependencies to tocheck list

## If a script needs dependencies checking, invoke the wizard.

## Suggested protocol: (but with only one # at start!)

## jsh-depends: <jsh_scripts>
## jsh-ext-depends: <real_progs>
## jsh-depends-ignore: ...
## jsh-ext-depends-ignore: ...
## jsh-depends-tocheck: ...
## jsh-ext-depends-tocheck: ...

## Note: instead of commenting out, the first two could be sourced and checked at runtime.

## Turn off default mode which asks user to resolve new dependencies:
# export DEPWIZ_NON_INTERACTIVE=true

## Makes getjshdeps and getextdeps less lazy: they will check for new dependencies even if some have already been defined.
## You want this on if any of the scripts may have been changed since its dependencies were defined.  (Should really be on by default, but SLOW if user only wants to compile scripts whose dependencies are valid (ie. on up-to-date jsh's, should be able to default off!), and FORCES INTERACTION unless DEPWIZ_NON_INTERACTIVE is set.)  Recommended solution: jsh developers have DEPWIZ_VIGILANT set, but by default it is off.  Or, invert the meaning of the boolean, but have neat checkouts set the var.
## Vigilance is not needed in order to include dependencies for scripts for which no dependency info has been generated, because vigilant checking is normal for such scripts.
[ "$DEPWIZ_NOT_VIGILANT" ] || export DEPWIZ_VIGILANT=true

## Makes getjshdeps and getextdeps very lazy: they won't check even if the script has no dependency info of that type
# export DEPWIZ_LAZY=true

## If developer is lazy, and happy to make a decision on every possible dependency, then <Enter> on query means Yes not Skip.
# export DEFAULT_TO_YES=true

## TODO: error exit if no line, but empty exit if empty line

## TODO: suggest removal of dependencies which findjshdeps no longer sees, but how to pin it in the rare case that it's OK?

function getrealscript () {
	if ! jwhich inj "$1"
	then
		error "Not found inj: $1"
		find "$JPATH/code/shellscript" -name "$1" -or -name "$1".sh | notindir CVS | head -n 1
	fi
}

function gendeps () {

		SCRIPT="$1"
		REALSCRIPT=`getrealscript "$SCRIPT"`

		echo "`cursemagenta`jshdepwiz: Checking dependencies for $SCRIPT`cursenorm`" >&2

		# FOUND_JSH_DEPS=`memo -f "$REALSCRIPT" findjshdeps "$SCRIPT" | grep " (jsh)$" | takecols 1 | grep -v "^$SCRIPT$" | tr '\n' ' '`
		FOUND_JSH_DEPS=`findjshdeps "$SCRIPT" | grep " (jsh)$" | takecols 1 | grep -v "^$SCRIPT$" | tr '\n' ' '`
		FOUND_EXT_DEPS=`findjshdeps "$SCRIPT" | grep -v " (jsh)$" | grep -v "^  " | takecols 1 | grep -v "^$SCRIPT$" | tr '\n' ' '`
		# replacelinestarting "$SCRIPT" "# jsh-depends:" " $JSH_DEPS"
		# replacelinestarting "$SCRIPT" "# jsh-depends:" " $JSH_DEPS"
		KNOWN_JSH_DEPS=`extractdep "$SCRIPT" depends depends-tocheck depends-ignore`
		KNOWN_EXT_DEPS=`extractdep "$SCRIPT" ext-depends ext-depends-tocheck ext-depends-ignore`
		# CURRENT_TODO_JSH_DEPS=`extractdep "$SCRIPT" depends-tocheck`
		# CURRENT_TODO_EXT_DEPS=`extractdep "$SCRIPT" ext-depends-tocheck`
		# [ "$KNOWN_JSH_DEPS" ] && SORTED_JSH_DEPS=`echo "$KNOWN_JSH_DEPS $CURRENT_TODO_JSH_DEPS" | tr ' ' '\n' | list2regexp` || SORTED_JSH_DEPS="^$"
		[ "$KNOWN_JSH_DEPS" ] && SORTED_JSH_DEPS=`echo "$KNOWN_JSH_DEPS" | tr ' ' '\n' | trimempty | list2regexp` || SORTED_JSH_DEPS="^$"
		[ "$KNOWN_EXT_DEPS" ] && SORTED_EXT_DEPS=`echo "$KNOWN_EXT_DEPS" | tr ' ' '\n' | trimempty | list2regexp` || SORTED_EXT_DEPS="^$"
		# echo "Echoing: $FOUND_JSH_DEPS   Ungrepping: $SORTED_JSH_DEPS" >&2
		NEW_JSH_DEPS=`echo "$FOUND_JSH_DEPS" | tr ' ' '\n' | grep -v "$SORTED_JSH_DEPS"`
		NEW_EXT_DEPS=`echo "$FOUND_EXT_DEPS" | tr ' ' '\n' | grep -v "$SORTED_EXT_DEPS"`
		# echo "# jsh-depends-tocheck: + $NEW_JSH_DEPS" >&2
		# echo "# jsh-ext-depends-tocheck: + $NEW_EXT_DEPS" >&2
		# [ "$NEW_JSH_DEPS" = "" ] && echo "`cursemagenta`jshdepwiz: No new dependencies found in $SCRIPT`cursenorm`" >&2
		# if [ "$NEW_JSH_DEPS" = "" ]
		# then
			# adddeptoscript "$REALSCRIPT" depends ""
		# fi
		addnewdeps depends $NEW_JSH_DEPS
		addnewdeps ext-depends $NEW_EXT_DEPS

		if [ "$DEPWIZ_NON_INTERACTIVE" ]
		then
			## Exit happy if no new deps
			[ ! "$NEW_JSH_DEPS" ] && [ ! "$NEW_EXT_DEPS" ]
		fi

}


function extractdep () {
	if [ "$1" = -err ]
	then RETURN_ERROR=true; shift
	fi
	SCRIPT="$1"
	REALSCRIPT=`getrealscript "$1"`
	shift
	for DEPTYPE
	do
		RES=`
			cat "$REALSCRIPT" |
			grep "^# jsh-$DEPTYPE:"
		`
		# [ ! "$?" = 0 ] && [ "$RETURN_ERROR" ] && debug "failed to find jsh-$DEPTYPE in $SCRIPT" && return 1
		[ ! "$?" = 0 ] && [ "$RETURN_ERROR" ] && return 1
		echo "$RES" |
		afterfirst :
		# sed 's+^# jsh-$DEPTYPE:++'
	done
}

function adddeptoscript () {
	REALSCRIPT="$1"
	DEPTYPE="$2"
	DEP="$3"
	LINESTART="# jsh-$DEPTYPE:"
	FINDLINE=`grep "^$LINESTART" "$REALSCRIPT"`
	# DEPS=`grep "^$LINESTART" "$REALSCRIPT" | sed 's+^$LINESTART++'`
	DEPS=`grep "^$LINESTART" "$REALSCRIPT" | afterfirst : | tr '\n' ' '`
	DEPS=`echo " $DEPS " | tr -s ' '`
	if grep "^$LINESTART" "$REALSCRIPT" > /dev/null
	then NEW_ENTRY=
	else NEW_ENTRY=true
	fi
	## Skip adding if dependency is already listed
	if ! echo "$DEPS" | grep "\<$DEP\>" > /dev/null
	then
		NEWSCRIPT=/tmp/newscript
		if [ "$NEW_ENTRY" ]
		then
			debug "NEW_ENTRY"
			(
				if head -n 1 "$REALSCRIPT" | grep "^#!" > /dev/null
				then DROP=1
				else DROP=0
				fi
				cat "$REALSCRIPT" |
				head -$DROP
				echo "$LINESTART$DEPS$DEP"
				cat "$REALSCRIPT" |
				awkdrop $DROP
			) > $NEWSCRIPT
		else
			cat "$REALSCRIPT" |
			sed "s+^$LINESTART.*+$LINESTART$DEPS$DEP+" |
			cat > $NEWSCRIPT
		fi
		if ! cmp "$REALSCRIPT" "$NEWSCRIPT" > /dev/null
		then
			echo "Made changes to $REALSCRIPT (backup in .b4jdw):" >&2
			diff "$REALSCRIPT" "$NEWSCRIPT" >&2
			# echo -n "`curseyellow`jshdepwiz: Are you happy with the suggested changes to the file? [Yn] `cursenorm`" >&2
			# read USER_SAYS
			# case "$USER_SAYS" in
				# y|Y|"")
					cp "$REALSCRIPT" "$REALSCRIPT.b4jdw" ## backup
					cp $NEWSCRIPT "$REALSCRIPT"
				# ;;
			# esac
		fi
	fi
}

function addnewdeps () {
	TYPE="$1"
	shift
	for DEP
	do
		if [ "$DEPWIZ_NON_INTERACTIVE" ]
		then
			# echo "New dep $DEP not added to $SCRIPT because DEPWIZ_NON_INTERACTIVE." >&2
			# echo "$DEP? " >&2
			# jshwarn "Vigilance suggests '$DEP' may be a dependency, but non-interactiveness means we aren't including it, or are we?  We probably should!"
			jshwarn "jshdepwiz: Unchecked possible dependency of $SCRIPT on '$DEP'"
			## Actually I think this is ok.  Provided lazy isn't on, DEPWIZ_NON_INTERACTIVE or empty dependencies will cause a re-gendeps, which means the whole set gets returned.
		else
			echo "`curseyellow`jshdepwiz: These might be calls to `cursered;cursebold`$DEP`curseyellow` made from `cursecyan`$SCRIPT`curseyellow`:`cursenorm`" >&2
			higrep "\<$DEP\>" -C1 "$REALSCRIPT" | sed 's+^+  +' >&2
			[ "$DEFAULT_TO_YES" ] && OPTIONS="Y/n/skip" || OPTIONS="Skip/y/n"
			echo -n "`curseyellow`jshdepwiz: Do you think `cursered;cursebold`$DEP`curseyellow` is a real `cursemagenta`jsh-$TYPE`curseyellow`? [$OPTIONS] `cursenorm`" >&2
			read USER_SAYS
			[ "$DEFAULT_TO_YES" ] && [ "$USER_SAYS" = "" ] && USER_SAYS=y
			case "$USER_SAYS" in
				n|N|no|NO|No)
					adddeptoscript "$REALSCRIPT" "$TYPE"-ignore "$DEP"
				;;
				y|Y|yes|YES|Yes)
					adddeptoscript "$REALSCRIPT" "$TYPE" "$DEP"
				;;
				*)
					echo "Not making any changes to $REALSCRIPT" >&2
				;;
			esac
			echo >&2
		fi
	done
}

case "$1" in

	getjshdeps)

		SCRIPT="$2"

		JSH_DEPS=`extractdep -err "$SCRIPT" depends`
		## Should we do a vigilant check by re-generating the dependencies?
		if [ "$DEPWIZ_VIGILANT" ] || ( [ ! "$?" = 0 ] && [ ! "$DEPWIZ_LAZY" ] )
		then
			## If new dependencies were found, but were not checked (non-interactive), then add them anyway:
			gendeps "$SCRIPT" || ADD="$NEW_JSH_DEPS "
			JSH_DEPS="$ADD"`extractdep "$SCRIPT" depends`
		fi
		echo "$JSH_DEPS"

	;;

	getextdeps)

		SCRIPT="$2"

		EXT_DEPS=`extractdep -err "$SCRIPT" ext-depends`
		if [ "$DEPWIZ_VIGILANT" ] || ( [ ! "$?" = 0 ] && [ ! "$DEPWIZ_LAZY" ] )
		then
			## If new dependencies were found, but were not checked (non-interactive), then add them anyway:
			gendeps "$SCRIPT" || ADD="$NEW_EXT_DEPS "
			EXT_DEPS="$ADD"`extractdep "$SCRIPT" ext-depends`
		fi
		echo "$EXT_DEPS"

	;;

	gendeps)

		gendeps "$2"

	;;

	*)

		if [ ! "$1" = --help ]
		then echo "jshdepwiz: command \"$*\" not recognised."
		fi

		echo
		echo "jshdepwiz [ getjshdeps | getextdeps | gendeps ] <scriptname>"
		echo
		echo "  getjshdeps and getextdeps extract meta-data from the script."
		echo
		echo "  gendeps uses heuristics to identify the script's dependencies, and"
		echo "    requests developer feedback before writing the meta-data."
		echo

	;;

esac
