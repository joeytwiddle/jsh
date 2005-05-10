if [ "$1" = "" ] || [ "$1" = "--help" ]
then

	echo
	echo "jdoc <command>"
	echo
	echo "  will show you the documentation for the command, be it unix or jsh,"
	echo "  and, if requested, will show uses of that command in all jsh scripts."
	echo
	echo "  You can find the list of jsh scripts in \$JPATH/tools/"
	echo
	echo "  jdoc also has a feature which helps you to refactor (rename) jsh scripts."
	echo

elif [ "$1" = -hasdoc ]
then

	## Internal: checks if script will accept --help argument and provide meaningful help back.

	## (TODO: we could also attempt this on binaries!)
	# if grep '\-\-help' "$LINKTOCOM" > /dev/null
	[ "$DEBUG" ] && debug "jdoc: looking for --help in $2"
	head -n 500 "$2" | grep '\-\-help' > /dev/null	
	exit "$?"

elif [ "$1" = showjshtooldoc ]
then

		LINKTOCOM="$2"

			(

				barline() {
					echo "::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
				}

				## If the script appears to accept the --help argument, then run <script> --help !
				if jdoc -hasdoc "$LINKTOCOM"
				then
					barline
					echo "Help: "`curseyellow`"$LINKTOCOM --help"`cursenorm`
					barline
					$LINKTOCOM --help
					echo
				fi

				## Show the script:
				barline
				echo "Code: `cursecyan`"`realpath "$LINKTOCOM"``cursenorm`
				barline

				cat "$LINKTOCOM" |

				## Pretty print it
				## (I'd like to use a dedicated program with syntax highlighting)
				## (Nah actually I quite like this implementation, it matches my coding policies!)
				highlight -bold "^[ 	]*\#\#.*" yellow | ## BRIGHT double-hashed comment, probable documentation
				# highlight "[^#]\# [A-Z].*" cyan | ## for lines likely to be a sentence
				highlight "^[ 	]*\# .*" magenta | ## DARK single-hashed comment, probably commented out code
				# highlight "	" blue | ## tabs
				# sed 's+	+|--+g' | ## tabs
				cat

				echo
				barline

			) | more

else

	## First pop up the manpage if it exists:
	## TODO/BUG: Should detach this from the shell, because Ctrl+C on the question following causes manpopup window to close.
	## Forget it: now handled by jman alias.
	# manpopup "$@" # &&
	# info "$@"

	LINKTOCOM="$JPATH/tools/$1"

	if [ -f "$LINKTOCOM" ]
	then

		## I decided popping up was not always desirable behaviour; so shifted it into manpoup.
		# if xisrunning
		# then
			# bigwin jdoc showjshtooldoc "$LINKTOCOM"
		# else
			jdoc showjshtooldoc "$LINKTOCOM"
		# fi

	fi

	## TODO: If this script was called as "man", (and there is no such shellscript(?)), then don't do this:
	##       But always do it if the script is called as jdoc.
	##       Yeah I think it would be good to do it if it was called as man, but a jsh script was found.  (think jsh's full-on man intercept when relevant)
	echo
	jshquestion "Would you like to see (uses of|dependencies on) `cursecyan`$1`cursenorm` in jsh? [yN] "
	read KEY
	echo
	case "$KEY" in

		y|Y)

			TABCHAR=`echo -e "\011"`
			cd $JPATH/tools/
			higrep "\<$1\>" -C2 *
			# BEGIN=`printf "\r"`
			# UP=`printf "\005"`
			# higrep "\<$1\>" -C2 * |
			# sed "s+^+$BEGIN$UP+"

			echo
			echo -n "Would you like to replace all occurrences of `cursecyan`$1`cursenorm` in jsh? [yN] "
			read KEY
			case "$KEY" in
				y|Y)
					echo "Warning: experimental; target should be unique!  Won't rename script file.  Ctrl+C to skip."
					echo "In fact: doesn't work, because changed scripts end up in $JPATH/tools not /shellscript."
					echo "         (depending on your sedreplace implementation)"
					echo -n "Replace `cursecyan`$1`cursenorm` with what? `cursecyan`"
					read REPLACEMENT
					cursenorm
					cd $JPATH/code/shellscript
					# find . -type f | notindir CVS |
					# foreachdo sedreplace "\<$1\>" "$REPLACEMENT"
					find . -type f | notindir CVS |
					withalldo grep -l "\<$1\>" |
					withalldo sedreplace "\<$1\>" "$REPLACEMENT"
					echo "If there is a script named $1, it should be renamed on the CVS server with: mvcvs .../$1 .../$REPLACEMENT"
				;;
			esac

		;;

		*)
			[ "$$" = 123 ] && jshinfo "Didn't think so."
			[ "$$" = 1234 ] && jshinfo "Guessed as much."
			[ "$$" = 12345 ] && echo "Aren't you curious?!" >&2
		;;

	esac

fi
