if [ "$1" = "" ] || [ "$1" = "--help" ]
then

	echo "jdoc <command>"
	echo "  will show you the documentation for the command"
	echo "  and if requested usage of / dependencies on that command in all jsh scripts"

elif [ "$1" = -hasdoc ]
then

	head -100 "$2" | grep '\-\-help' > /dev/null	
	exit "$?"

elif [ "$1" = showjshtooldoc ]
then

		LINKTOCOM="$2"

			(
				barline() {
					echo "::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
				}
				## If if appears to accept the --help argument, then just run it!
				## (TODO: we could in fact attempt this on binaries!)
				# if grep '\-\-help' "$LINKTOCOM" > /dev/null
				if jdoc -hasdoc "$LINKTOCOM"
				then
					barline
					curseyellow
					echo "$LINKTOCOM --help"
					cursenorm
					barline
					$LINKTOCOM --help
					echo
				fi
				## Show the script:
					barline
					cursecyan
					echo `justlinks "$LINKTOCOM"`
					cursenorm
					barline
					cat "$LINKTOCOM" |
					## Pretty print it (I'd like to use a dedicated program with syntax highlighting)
					highlight "\#\#.*" yellow | ## for comments
					highlight "[^#]\# [A-Z].*" cyan | ## for lines likely to be a sentence
					highlight "	" blue | ## tabs
					# sed 's+	+|--+g' | ## tabs
					cat
					echo
					barline
				## TODO: might the user want the man page as well as the script?
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

		if xisrunning
		then
			bigwin jdoc showjshtooldoc "$LINKTOCOM"
		else
			jdoc showjshtooldoc "$LINKTOCOM"
		fi

	fi

	## TODO: If this script was called as "man", (and there is no such shellscript(?)), then don't do this:
	##       But always do it if the script is called as jdoc.
	##       Yeah I think it would be good to do it if it was called as man, but a jsh script was found.  (think jsh's full-on man intercept when relevant)
	echo
	echo -n "Would you like to see (uses of|dependencies on) `cursecyan`$1`cursenorm` in jsh? [yN] "
	read KEY
	echo
	case "$KEY" in y|Y)
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
		case "$KEY" in y|Y)
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
		esac

	esac

fi
