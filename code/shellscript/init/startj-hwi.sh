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
			[ "$DEBUG" ] && echo "startj: sourcing $HOME/.bash_profile" >&2
			. $HOME/.bash_profile
		fi
		## Note: this elif (as opposed to fi \n if) assumes .bash_profile always sources .bashrc (like my Debian one)
		# elif [ -f $HOME/.bashrc ]
		if [ -f $HOME/.bashrc ]
		then
			[ "$DEBUG" ] && echo "startj: sourcing $HOME/.bashrc" >&2
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

	if [ $OKTOSTART ]
	then

		[ "$DEBUG" ] && echo "startj: starting jsh system" >&2

		PATHBEFORE="$PATH"
		export PATH="$JPATH/tools:$HOME/bin:$PATH"

		if ALREADY=`jwhich jsh`
		then

			export PATH="$PATHBEFORE"
			echo "Warning: found different set of jsh tools in your PATH at $ALREADY." >&2
			echo "JPATH must have been altered, possibly by a different call to jsh." >&2
			echo "Reverted PATH to avoid bouncing between them." >&2
			## TODO: should deal with this better by clearing old jsh tools from PATH

		else

			test -f "$JPATH/global.conf" && . "$JPATH/global.conf"
			test -f "$JPATH/local.conf" && . "$JPATH/local.conf"

			## Setup user bin, libs, man etc...
			# export PATH=$HOME/bin:$PATH
			## not yet finished, should be option - refer to setuppath in pclark/pubbin

			# zsh on Solaris gives errors on . so I use source

			. javainit
			. hugsinit

			### NB: On Hwi with /bin/sh ". startj simple" does not provide "simple" in $1 !

			if test ! "$1" = "simple"; then

				## TODO: Separate scripts which need to run to init stuff for runtime
				##       from scripts which do stuff that isn't dependent for later.

				# mytime . getmachineinfo
				. getmachineinfo

				## Which flavour shell are we running?
				if test $ZSH_NAME; then
					SHORTSHELL="zsh"
					. zshkeys
					. hwipromptforzsh
					## TODO: problem, this can leave nonomatch in $1 of sourced scripts (in the interactive sh)
					setopt nonomatch
				elif test "$BASH"; then
					SHORTSHELL="bash"
					. bashkeys
					. hwipromptforbash
					shopt -s cdspell checkhash checkwinsize cmdhist dotglob histappend histreedit histverify hostcomplete mailwarn no_empty_cmd_completion shift_verbose
				fi
				## TODO: if neither zsh or bash, we should establish SHORTSHELL with whatshell (heavy), cos it's needed for xttitleprompt

				. joeysaliases
				. cvsinit

				# . dirhistorysetup.bash
				. dirhistorysetup.zsh
				. lscolsinit

				alias cvshwi='cvs -z6 -d :pserver:joey@hwi.ath.cx:/stuff/cvsroot'
				alias cvsimc='cvs -d :pserver:anonymous@cat.org.au:/usr/local/cvsroot'
				alias cvsenhydra='cvs -d :pserver:anoncvs@enhydra.org:/u/cvs'

				export FIGNORE=".class"

				## Avoid error if not on a tty
				## Nice try Joey but doesn't work on kimo.
				# if test ! "$BAUD" = "0"; then
					mesg y
				# fi

				## Message on user login/out (zsh, tcsh, ...?)
				export WATCH=all

				. xttitleprompt

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
