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
## Makes getjshdeps and getextdeps less lazy: they will always check for ext links
# export DEPWIZ_VIGILANT=true
## Makes getjshdeps and getextdeps very lazy: they won't check even if the script has no dependency info of that type
# export DEPWIZ_LAZY=true

## TODO: error exit if no line, but empty exit if empty line

## TODO: suggest removal of dependencies which findjshdeps no longer sees, but how to pin it in the rare case that it's OK?

function getrealscript () {
	if ! jwhich inj "$1"
	then
		error "Not found inj: $1"
		find "$JPATH/code/shellscript" -name "$1" -or -name "$1".sh | notindir CVS | head -1
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
				if head -1 "$REALSCRIPT" | grep "^#!" > /dev/null
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
			echo "Making changes to: $REALSCRIPT (backup in .b4jdw)" >&2
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
			echo "$DEP? " >&2
			# echo "New dep $DEP not added to $SCRIPT because DEPWIZ_NON_INTERACTIVE." >&2
		else
			echo "`curseyellow`jshdepwiz: Calls to `cursered;cursebold`$DEP`curseyellow` are made in `cursecyan`$SCRIPT`curseyellow`:`cursenorm`" >&2
			higrep "\<$DEP\>" -C1 "$REALSCRIPT" | sed 's+^+  +' >&2
			echo -n "`curseyellow`jshdepwiz: Do you think `cursered;cursebold`$DEP`curseyellow` is a real `cursemagenta`jsh-$TYPE`curseyellow`? [Yn] `cursenorm`" >&2
			read USER_SAYS
			case "$USER_SAYS" in
				n|N|no|NO|No)
					adddeptoscript "$REALSCRIPT" "$TYPE"-ignore "$DEP"
				;;
				*)
					adddeptoscript "$REALSCRIPT" "$TYPE" "$DEP"
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
		if [ ! "$DEPWIZ_LAZY" ] && ( [ ! "$?" = 0 ] || [ "$DEPWIZ_VIGILANT" ] )
		then
			jshdepwiz gendeps "$SCRIPT"
			JSH_DEPS=`extractdep "$SCRIPT" depends`
		fi
		echo "$JSH_DEPS"

	;;

	getextdeps)

		SCRIPT="$2"

		EXT_DEPS=`extractdep -err "$SCRIPT" ext-depends`
		if [ ! "$DEPWIZ_LAZY" ] && ( [ ! "$?" = 0 ] || [ "$DEPWIZ_VIGILANT" ] )
		then
			jshdepwiz gendeps "$SCRIPT"
			EXT_DEPS=`extractdep "$SCRIPT" ext-depends`
		fi
		echo "$EXT_DEPS"

	;;

	gendeps)

		SCRIPT="$2"
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

	;;

	*)

		echo "jshdepwiz: command \"$*\" not recognised."
		exit 1

	;;

esac
