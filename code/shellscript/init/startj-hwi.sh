### B # l # o # a # t # e # d # ! #
## TODO: Offer config.global and config.local config files to ease customization and speed up startup
##       Create ". requiresenv <varname>..." script for checking for existence of neccessary shell environment variables, or exit with error.
##         As well as making dependent shellscripts safe, it will provide some indication to coders as to what inputs a script takes.
##       Further development on dependencies: find dependencies on binaries (=> packages) in PATH too, so that checks may be performed to ensure local sys meets the requirements of each shellscript.  Provide a dselect-like subset chooser.  (". requiresscripts <scriptname>...", ". requiresbins <command>...", ". requirespkgs <package>..." ?)

## TODO: When a new zsh or bash is started already in the jsh environment,
##       (eg. running xterm from within jsh)
##       all _exported_ environment variables will still be present
##       These need not be set all over again
##       It would be quicker if we could skip them.
##       Only aliases (and other shell specific stuff) need to be set.

## Are exits too harsh for a script which is likely to be sourced?
## Do we think it's OK because startj is run by jsh these days?

## Conclusive (?) proof that bash provides nothing to tell us where this script is when it is called with source.
## $_ comes out as previous command (the one called before source!)
# echo "\$\_ = >$_<" >&2
# echo "\$\0 = >$0<" >&2
# echo "\$\* = >$*<" >&2
# echo "\$\FUNCNAME = >$FUNCNAME<" >&2
# env > /tmp/env.out
# set > /tmp/set.out
# chmod a+w /tmp/env.out
# chmod a+w /tmp/set.out

## For jshstub bash support:
# alias .="'.' $JPATH/tools/joeybashsource"

# set -x
## in bash on a 486 told me that points of slowness WERE:
# jwhich jwhich
# startswith CYGWIN
# the runnable (which) checks in dirhistorysetup.zsh
# the business with JM_UNAME
# grepping the date in hwipromptforbash
## so I fixed a few of them.

# mytime () {
	# time "$@"
	# echo "$@"
# }

if [ ! $COUNT_STARTJ_RUN ]
then COUNT_STARTJ_RUN=0
fi
COUNT_STARTJ_RUN=`expr "$COUNT_STARTJ_RUN" + 1`
export COUNT_STARTJ_RUN

if [ "$STARTJ_BLOCK" ]
then echo "startj: Blocked ok (if ~/.bashrc sources startj, then jsh needn't start bash with startj as its rc script /and/ BASH_BASH set!)" >&2
else

	## Source bash's profile script (if we have replaced it with this script)
	## But be sure not to end up in an infinite loop!
	if [ "$BASH_BASH" ]
	then
		## Dangerous loop if user runs jsh from their .bashrc, so:
		export STARTJ_BLOCK=true
		# test -f "$BASH_BASH" &&
		# ! grep "\<jsh\>" "$BASH_BASH" > /dev/null &&
		# ! grep "\<startj\>" "$BASH_BASH" > /dev/null &&
		# . "$BASH_BASH"
		if [ -f $HOME/.bash_profile ]
		then
			[ "$JSHDEBUG" ] && echo "startj: sourcing $HOME/.bash_profile" >&2
			. $HOME/.bash_profile
		fi
		## Note: this elif (as opposed to fi \n if) assumes .bash_profile always sources .bashrc (like my Debian one)
		# elif [ -f $HOME/.bashrc ]
		if [ -f $HOME/.bashrc ]
		then
			[ "$JSHDEBUG" ] && echo "startj: sourcing $HOME/.bashrc" >&2
			. $HOME/.bashrc
		fi
		unset STARTJ_BLOCK
	fi

	lookslikejpath () {
		[ -f "$1/startj" ]
	}

	OKTOSTART=true

	## Try to guess the top directory of j install
	## If all below fails, then you should set it youself with export JPATH=...; source $JPATH/startj
	## TODO: Ensure JPATH is an absolute path (jsh may have been called relative to wd)
	##       Is that a problem?!  A previous initialised jsh should export JPATH, so presumably we can deal with that sensibly enough!
	if ! lookslikejpath $JPATH
	then
		## TODO: Create a list here then loop it.
		if lookslikejpath "$HOME/j"
		then export JPATH="$HOME/j"
		## Works for zsh, but only for bash if we call startj directly (not sourced).
		elif lookslikejpath `dirname "$0"`
		then export JPATH=`dirname "$0"`
		## Works for zsh, same problems with bash.  No point running it!
		# elif lookslikejpath `dirname "$0"`
		# then export JPATH=`dirname "$0"`
		else
			echo "startj: Could not find JPATH. Not starting." >&2
			OKTOSTART=
		fi
		# test "$OKTOSTART" && echo "startj: found JPATH=$JPATH" >&2
	fi

	[ -e "$HOME"/disable_jsh ] && OKTOSTART=

	if [ $OKTOSTART ]
	then

		[ "$JSHDEBUG" ] && echo "startj: starting jsh system" >&2

		PATHBEFORE="$PATH"
		# export PATH="$JPATH/tools:$HOME/bin:$PATH"
		export PATH="$PATH:$JPATH/tools:$HOME/bin"

		[ "$JSHDEBUG" ] && echo "Added $JPATH/tools to get new PATH=$PATH" >&2

		## Dunno about below checks.  This is new:
		PATH=`
			echo "$PATH" |
			tr : '\n' |
			while read EXEDIR
			do
				if [ ! "$EXEDIR" = "$JPATH"/tools ] && [ -x "$EXEDIR"/jsh ] && [ -x "$EXEDIR"/startj-hwi ]
				then
					jshwarn "$EXEDIR on you PATH looks like jsh, but not $JPATH/tools; so I'm removing it"
					# . removefrompath "$EXEDIR"
				else
					echo "$EXEDIR"
				fi
			done |
			# removeduplicatelinespo | ## neat but too heavy a dependenceny for jsh startup
			tr '\n' : | tr -s ":" | sed 's+:$++' ## last esp important to avoid . on PATH :P
		`

		[ "$JSHDEBUG" ] && echo "PATH is now $PATH" >&2

		if ALREADY=`jwhich jsh` && [ -d `dirname \`jwhich jsh\``/tools ]
		then

			export PATH="$PATHBEFORE"
			echo "Warning: found different set of jsh tools in your PATH at $ALREADY." >&2
			echo "JPATH must have been altered, possibly by a different call to jsh." >&2
			echo "Reverted PATH to avoid bouncing between them." >&2
			## TODO: should deal with this better by clearing old jsh tools from PATH

		else

			[ -f "$JPATH/global.conf" ] && . "$JPATH/global.conf"
			[ -f "$JPATH/local.conf" ] && . "$JPATH/local.conf"

			## Setup user bin, libs, man etc...
			# export PATH=$HOME/bin:$PATH
			## not yet finished, should be option - refer to setuppath in pclark/pubbin

			# zsh on Solaris gives errors on . so I use source

			. javainit
			. hugsinit

			### NB: On Hwi with /bin/sh ". startj simple" does not provide "simple" in $1 !

			if [ ! "$1" = "simple" ] && ! [ "$STARTJ_SIMPLE" ]
			then

				## TODO: Separate scripts which need to run to init stuff for runtime
				##       from scripts which do stuff that isn't dependent for later.

				## Gather hostname and username (used by screen, prompts, etc.)
				if [ ! "$SHORTHOST" ]
				then SHORTHOST="$HOSTNAME"
				fi
				if [ ! "$SHORTHOST" ]
				then SHORTHOST=`hostname`
				fi
				export SHORTHOST=`echo "$SHORTHOST" | beforefirst "\."`

				# mytime . getmachineinfo
				. getmachineinfo

				### Keybindings and pretty prompts:
				## Which flavour shell are we running?
				if [ $ZSH_NAME ]
				then
					SHORTSHELL="zsh"
					. zshkeys
					. hwipromptforzsh
					## TODO: problem, this can leave nonomatch in $1 of sourced scripts (in the interactive sh)
					setopt nonomatch
				elif [ "$BASH" ]
				then
					SHORTSHELL="bash"
					. bashkeys
					. hwipromptforbash
					shopt -s cdspell checkhash checkwinsize cmdhist dotglob histappend histreedit histverify hostcomplete mailwarn no_empty_cmd_completion shift_verbose
				fi
				## TODO: if neither zsh or bash, we should establish SHORTSHELL with whatshell (heavy), cos it's needed for xttitleprompt

				# export JSH_TITLING=true ## TODO: put this in default options - allows user to turn it off
				## Nope better to have an alias source a script to turn it off, since bash's are env-vars (not functions) so cannot test themselves, so should be cleared.
				. xttitleprompt

				. lscolsinit

				. joeysaliases

				# . dirhistorysetup.bash
				. dirhistorysetup.zsh

				. cvsinit

				alias cvshwi='cvs -z6 -d :pserver:joey@hwi.ath.cx:/stuff/cvsroot'
				alias cvsimc='cvs -d :pserver:anonymous@cat.org.au:/usr/local/cvsroot'
				alias cvsenhydra='cvs -d :pserver:anoncvs@enhydra.org:/u/cvs'

				BOGOMIPS=`cat /proc/cpuinfo | grep bogomips | afterfirst ': ' | beforelast '\.'`

				if [ "$BOGOMIPS" ] && [ "$BOGOMIPS" -gt 500 ]
				then
					if [ "$BASH" ] && [ -f /etc/bash_completion ]
					then
						[ "$JSHDEBUG" ] && debug "Tab completion: loading /etc/bash_completion"
						. /etc/bash_completion
						## But it wasn't working (when I did su - <a_user> from root).
					## Disabled because "ls --col"<Tab> didn't work:
					## Besides, testing jsh's autocomplete_from_man is my priority!
					# elif [ "$ZSH_NAME" = zsh ] && [ -f $HOME/.zsh_completion_rules ]
					# then
						# [ "$JSHDEBUG" ] && debug "Tab completion for zsh: loading $HOME/.zsh_completion_rules"
						# . $HOME/.zsh_completion_rules
					# else
						# [ "$JSHDEBUG" ] && debug "Tab completion: loading jsh:autocomplete_from_man"
						# . autocomplete_from_man
					fi
					[ "$JSHDEBUG" ] && debug "Tab completion: loading jsh:autocomplete_from_man"
					. autocomplete_from_man
				fi

				export FIGNORE=".class"

				## Avoid error if not on a tty
				## Nice try Joey but doesn't work on kimo.
				# if test ! "$BAUD" = "0"; then
					mesg y
				# fi

				## Message on user login/out (zsh, tcsh, ...?)
				export WATCH=all

				### Better solution in jsh.
				# ## If user prefers zsh but has not sourced startj in their .zshrc,
				# ## then jsh needs this hack so that it may call zsh $JPATH/startj
				# if test "$BASH_ZSH"
				# then
					# ## If zsh sources .zshrc which sources startj, don't run zsh again!
					# unset BASH_ZSH
					# ## but don't block startj, because we want to leave its aliases in zsh
					# # export STARTJ_BLOCK=true
					# zsh
					# # unset STARTJ_BLOCK
				# fi
				# ## Doesn't really work because aliases etc get dropped.

			fi # ! simple

		fi # jwhich jwhich

	fi # OKTOSTART

fi # STARTJ_BLOCK
