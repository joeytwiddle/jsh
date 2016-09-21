#!/bin/bash
## Should add detection of whether info file == man page ;p

if [ "$1" = "" ] || [ "$1" = "--help" ]
then

cat << !

Usage: jdoc [ <scriptname> | <part_of_script_name> ]

  will show you the documentation for the jsh script (TODO: or PATH script),
  and, if requested, will show uses of that script in all jsh scripts.

  It is safer to use than <scriptname> --help, which could do something
  undesirable on very raw scripts.  However it will actually call
  <scriptname> --help if it believes it is safe to do so!

  Either way, it will also color-print the script for your perusal.

  If you ask to see usage of/dependencies on the script, jdoc will also offer
  to refactor (rename) that jsh script.  Only use this if you *really* hate the
  name of the script, and wish it were called something else - it will affect
  updates!  (Alternatively, make a symlink from your alias to the script.)

  You can find the list of jsh scripts in \$JPATH/tools/

Advanced usage: jdoc [ -hasdoc | showjshtooldoc ] <path_to_script>

!

elif [ "$1" = -hasdoc ]
then

	## Internal: checks if script will accept --help argument and provide meaningful help back.

	## (TODO: we could also attempt this on binaries!)
	# if grep '\-\-help' "$LINKTOCOM" > /dev/null
	[ "$DEBUG" ] && debug "jdoc: looking for --help in $2"
	head -n 100 "$2" |
	# grep '\-\-help' > /dev/null	
	## More advanced: on not-commented lines, finds occurrences of:  = "--help  ||  = '--help  ||  = --help  ||  --help)
	grep "[^#]*\(= [\"']{0,1}--help\|--help)\)" > /dev/null
	exit "$?"

elif [ "$1" = showjshtooldoc ]
then

		LINKTOCOM="$2"

			(

				barline() {
					echo "::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
				}

				## If the script appears to accept the --help argument, then run <script> --help !
				if verbosely jdoc -hasdoc "$LINKTOCOM"
				then
					barline
					echo "Help: "`curseyellow`"$LINKTOCOM --help"`cursenorm`
					barline
					## BUG TODO: should check it is -x executable, currently bards on libs / sourced scripts.
					verbosely $LINKTOCOM --help
					echo
				fi

				## Show the script:
				barline
				echo "Code: `cursecyan`"`realpath "$LINKTOCOM"``cursenorm`
				barline

				cat "$LINKTOCOM" |
				### Pretty print shellscript documentation (add colours)
				(
					## (I'd like to use a dedicated program with syntax highlighting)
					## (Nah actually I quite like this implementation, it matches my coding policies!)
					## Variables:
					## A shell variable, declaration or usage (-bold for BRIGHT)
					highlight "[$][A-Za-z0-9_][A-Za-z0-9_]*" cyan |
					highlight "^[A-Za-z0-9_][A-Za-z0-9_]*=" cyan |
					## Strings:
					highlight '"' green |
					## Comments:
					## Double-hashed comment, probable documentation (-bold for BRIGHT)
					highlight "^[ 	]*\#\#.*" yellow |
					## Special comments:
					# highlight "[^#]\# [A-Z].*" cyan | ## for lines likely to be a sentence
					## Normal comments (single #), coloured dark.  Possibly code which was commented out.  Is hash followed by space?
					highlight "^[ 	]*\# .*" magenta |
					# highlight "	" blue | ## tabs
					# sed 's+	+|--+g' | ## tabs
					## Special comments:
					# highlight "^\\(TODO\|DONE\|WARN\|BUG\\).*" red |
					highlight -bold "\\(TODO\|DONE\|WARN\|BUG\\).*" red |
					cat
				)

				echo
				barline

			) | less -REX

else

	## First pop up the manpage if it exists:
	## TODO/BUG: Should detach this from the shell, because Ctrl+C on the question following causes manpopup window to close.
	## Forget it: now handled by jman alias.
	# manpopup "$@" # &&
	# info "$@"

	## Compromise with failed attempt below:

	LINKTOCOM="$JPATH/tools/$1"

	## Allow the user to glob the script's name: (note we only get here if $1 was a jsh script, and we ignore $2,... and WARN TODO BUG: below we refer to $1 instead of the glob we are on.)
	# for LINKTOCOM in "$JPATH/tools/"$1
	# do

		if [ -f "$LINKTOCOM" ]
		then

			l "$LINKTOCOM"

			## I decided popping up was not always desirable behaviour; so shifted it into manpoup.
			# if xisrunning
			# then
				# bigwin jdoc showjshtooldoc "$LINKTOCOM"
			# else
				jdoc showjshtooldoc "$LINKTOCOM"
			# fi

		else

			# jshwarn "No jsh script found at '$LINKTOCOM'."
			jshinfo "There is no jsh script called '$1'."

			w=`which "$1"`
			orp=P
			if [ ! -z "$w" ]
			then
				echo
				echo "  But there is an executable: `cursered;cursebold`$w`cursenorm`"
				orp="Or p"
			fi

			# PERHAPS=`cd "$JPATH/tools" ; find . -maxdepth 1 -type l`
			PERHAPS=`cd "$JPATH/tools" ; echolines * | grep "$1"`
			if [ ! -z "$PERHAPS" ]
			then
				echo
				jshinfo "$orp""erhaps you were looking for one of the following:"
				echo
				echo "$PERHAPS" |
				# highlight "$1" green | prepend_each_line "  "
				# foreachdo onelinedescription
				while read SCRIPT
				do
					folder="`realpath "$JPATH/tools/$SCRIPT" | beforelast / | afterlast /`" 
					# echo -n "  $SCRIPT:\t"
					# onelinedescription "$SCRIPT"
					DESCR=`onelinedescription "$SCRIPT"`
					if [ "$DESCR" = "???" ] || [ "$DESCR" = "" ]
					then
						echo "  [`cursegreen`$folder`cursenorm`] `cursered;cursebold`$SCRIPT`cursenorm`"
					else
						echo "  [`cursegreen`$folder`cursenorm`] `cursered;cursebold`$SCRIPT`cursenorm`	$DESCR"
					fi
				done
			fi

		fi

		## It is a bit unusual to ask users this question if the script did not
		## exist.  However I do sometimes use this feature to scan jsh scripts
		## for a given regexp.

		## Likewise the followthrough below is a bit over-powerful for normal
		## users.  Perhaps the behaviour of these features should be reduced to
		## mortal level, with exported config options unlocking the more powerful
		## features.

		## TODO: If this script was called as "man", (and there is no such shellscript(?)), then don't do this:
		##       But always do it if the script is called as jdoc.
		##       Yeah I think it would be good to do it if it was called as man, but a jsh script was found.  (think jsh's full-on man intercept when relevant)
		echo
		jshquestion "Would you like to see (uses of|dependencies on) `cursecyan`$1`cursenorm` in jsh? [yN] "
		read KEY
		echo
		case "$KEY" in

			y|Y)

				# cd $JPATH/tools/
				# higrep "\<$1\>" -C2 * |
				# more
				# # BEGIN=`printf "\r"`
				# # UP=`printf "\005"`
				# # higrep "\<$1\>" -C2 * |
				# # sed "s+^+$BEGIN$UP+"
				## I wanted to add the ability to search more than just the local jsh tools.
				## But actually there are shellscripts scattered all over my other-language projects.  We would need a sophisticated index to find them all in order to do a full search.
				# So uh Ubuntu (12.04)'s grep -r *ignores* symlinks.
				#SCRIPT_PATH_SEARCH="$JPATH/tools/ ...
				SCRIPT_PATH_SEARCH="$JPATH/code/shellscript/ $JPATH/code/other/cgi/ $JPATH/code/other/web/ /mnt/hwibot/usr/lib/cgi-bin/"
				highlightstderr grep "\<$1\>" -C2 -r $SCRIPT_PATH_SEARCH 2>&1 |
				grep -v 'grep: .* No such file or directory' |
				sed -u "s+^$JPATH/code/shellscript/++" |
				highlight "\<$1\>" |
				highlight -bold "^[^ :-]*" cyan |
				less -REX

				echo
				jshquestion "Would you like to replace all occurrences of `cursecyan`$1`cursenorm` in jsh? [yN] "
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

	# done

fi
