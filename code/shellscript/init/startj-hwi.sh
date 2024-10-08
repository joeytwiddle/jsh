# @sourceme

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

## Speedup debugging:
## Why shell starts so much faster on hwibot than hwi?
## Gah I worked out part of the cause for that, but forgot it.  Well at least I made a comment about this, hooray!
## I know one of our slowdowns is due to the huge size of $JPATH/tools and the fact that everything in there is symlinked!
## So one experiment could be to copy scripts out of $JPATH/code/shellscript and into $JPATH/tools or something!
[ "$DEBUG" ] && JSH_SHOW_TIMING=true
# JSH_SHOW_TIMING=true
# JSH_LITE=true

dateDiff() {
	[ -z "$JSH_SHOW_TIMING" ] && return 0

	# BSD date does not do nanoseconds.  So for Mac, we look for locally installed GNU date.
	# (BUG: If it is not present, we will end up using BSD date, which will cause errors.)
	local date_cmd
	date_cmd=/usr/local/opt/coreutils/libexec/gnubin/date
	[ -x "$date_cmd" ] || date_cmd="date"

	newDate="$("$date_cmd" +"%s%N")"
	[ -z "$oldDate" ] && oldDate="$newDate"

	dateDiff="$(expr "$newDate" - "$oldDate")"

	#echo "[$0] took ($dateDiff) to do $*" >&2
	printf "[%s] took % 11dms to do %s\n" "$0" "$dateDiff" "$*" >&2

	oldDate="$newDate"
}

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

	dateDiff "JSH starting"

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
		## Not everyone wants $HOME/bin
		# export PATH="$JPATH/tools:$HOME/bin:$PATH"
		# export PATH="$PATH:$JPATH/tools:$HOME/bin"
		export PATH="$PATH:$JPATH/tools"

		# $SHLVL|
		## The xterm check is actually to prevent stderr from firing error emails during cron scripts.  We might instead check we are in an interactive (or even better, "visible") shell.
		[ "$TERM" = xterm ] && echo -n "`cursegreen`[jsh...`cursenorm`" >&2

		[ "$JSHDEBUG" ] && echo "Added $JPATH/tools to get new PATH=$PATH" >&2

		## If there is any other jsh on the PATH then remove it
		## Note that we need the '\n' in the printf, or the last entry won't be read!
		## Do not put comments _inside_ this block.  zsh 5 (Manjaro) did not like it.
		PATH="$(
			printf "%s\n" "$PATH" |
			tr ':' '\n' |
			while read EXEDIR
			do
				if [ ! "$EXEDIR" = "$JPATH"/tools ] && [ -x "$EXEDIR"/jsh ] && [ -x "$EXEDIR"/startj-hwi ]
				then
					jshwarn "$EXEDIR on you PATH looks like jsh, but not $JPATH/tools; so I'm removing it"
				else
					printf "%s:" "$EXEDIR"
				fi
			done |
			tr -s ':' | sed 's/:$//'
		)"
		## The last sed is important to prevent an empty entry (equivalent to `.`) from appearing on the PATH

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

			# Alright now things get gnarly
			# A few of the following add to LD_LIBRARY_PATH
			# Probably most users won't want this, so make it part of joey's config not jsh!
			# Also it has a nasty bug, that ":/foo/bar" consumes the first entry
			# as "." which is considered insecure with $PATH and likewise for LD_LIBRARY_PATH.
			# As a workaround until the entries are removed:
			[ -z "$LD_LIBRARY_PATH" ] && LD_LIBRARY_PATH="/usr/lib"

			# zsh on Solaris gives errors on . so I use source
			# forget why I switched back to using .

			. javainit
			. hugsinit

			### NB: On Hwi with /bin/sh ". startj simple" does not provide "simple" in $1 !

			if [ ! "$1" = "simple" ] && ! [ "$STARTJ_SIMPLE" ]
			then

				dateDiff "JSH stage 1"

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

				## Sets up a few JM_.... variables, which are used by joeysaliases, dar, dsr, dusk, xtermopts and others!
				# mytime . getmachineinfo
				# . getmachineinfo

				dateDiff "JSH stage 2"

				### Keybindings and pretty prompts:
				## Which flavour shell are we running?
				if [ $ZSH_NAME ]
				then
					SHORTSHELL="zsh"
					# export JSH_TITLING=true ## TODO: put this in default options - allows user to turn it off
					## Nope better to have an alias source a script to turn it off, since bash's are env-vars (not functions) so cannot test themselves, so should be cleared.
					. zshkeys
					. hwipromptforzsh

					### Options for zsh
					## Act like bash: if a glob is provided with no matches, don't complain, just apply it
					setopt nonomatch
					HISTSIZE=10000
					SAVEHIST=50
					# setopt HIST_NO_STORE
					setopt HIST_IGNORE_DUPS HIST_REDUCE_BLANKS
					# I don't need HIST_VERIFY on zsh, because I perform tab-completion first if I am unsure.

				elif [ "$BASH" ]
				then
					SHORTSHELL="bash"
					. bashkeys
					. hwipromptforbash

					### Options for bash
					# cdspell: Correct minor mistakes when using cd builtin (but not when using aliased cd=d)
					# histverify: When expanding !, don't run the command immediately, show the expansion first.
					#   Without this !<something><Enter> can be quite dangerous, if an unexpected line is run.
					# checkwinsize: updates LINES and COLUMNS
					# cmdhist: allows re-editing of multiple-line histories
					# ...
					shopt -s cdspell checkhash checkwinsize dotglob histappend histreedit histverify hostcomplete mailwarn no_empty_cmd_completion shift_verbose
					# Disabled (under consideration): cmdhist

					# bind "set bell-style none"
					## On iTerm2 this displays an error, so we suppress errors
					bind "set bell-style visual" 2>/dev/null
				fi
				## TODO: if neither zsh or bash, we should establish SHORTSHELL with whatshell (heavy), cos it's needed for xttitleprompt.
				##       for the moment, we don't start xttitleprompt
				## SHORTSHELL is also used in joeysaliases (and term_state).

				. lscolsinit

				. joeysaliases

				# . dirhistorysetup.bash
				. dirhistorysetup.zsh

				dateDiff "JSH stage 3"

				if [ ! "$JSH_LITE" ]
				then

					## Was not working when it was sourced before bashkeys.
					. xttitleprompt

					. cvsinit

					dateDiff "JSH stage 4"

					if [ -f /proc/cpuinfo ]
					then BOGOMIPS=`cat /proc/cpuinfo | grep bogomips | head -n 1 | afterfirst ': ' | beforelast '\.'`
					else BOGOMIPS=1000   # Just assume, e.g. for Mac OS X
					fi

					if [ -n "$BOGOMIPS" ] && [ "$BOGOMIPS" -gt 500 ]
					then
						if [ -n "$BASH" ] && [ -f /etc/bash_completion ]
						then
							[ -n "$JSHDEBUG" ] && debug "Tab completion: loading /etc/bash_completion"
							. /etc/bash_completion
							## But it wasn't working (when I did su - <a_user> from root).
						## Disabled because "ls --col"<Tab> didn't work:
						## Besides, testing jsh's autocomplete_from_man is my priority!
						# elif [ "$ZSH_NAME" = zsh ] && [ -f $HOME/.zsh_completion_rules ]
						# then
						# 	[ -n "$JSHDEBUG" ] && debug "Tab completion for zsh: loading $HOME/.zsh_completion_rules"
						# 	. $HOME/.zsh_completion_rules
						# else
						# 	[ -n "$JSHDEBUG" ] && debug "Tab completion: loading jsh:autocomplete_from_man"
						# 	. autocomplete_from_man
						fi
						# autocomplete_from_man will throw a parse error (syntax error) on some older shells, even for lines than don't run, so we only run it for known-good shells.
						# if [ -n "$BASH" ] || [ -n "$ZSH_NAME" ]
						# then
						# 	[ -n "$JSHDEBUG" ] && debug "Tab completion: loading jsh:autocomplete_from_man"
						# 	. autocomplete_from_man
						# fi
					fi

					dateDiff "JSH stage 5"

					export FIGNORE=".class"

					## Prints a message when another user logs in or out (works in zsh, tcsh, ...?)
					## This is more useful on a shared server than it is on a desktop.
					# WATCH=all

					## Accept messages sent by other users (only on a tty)
					if [ -t 1 ]
					then mesg y
					fi

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

				fi

			fi # ! simple

		fi # jwhich jwhich

		dateDiff "JSH done"

		[ "$TERM" = xterm ] && echo "`cursegreen`started]`cursenorm`" >&2

	fi # OKTOSTART

fi # STARTJ_BLOCK
