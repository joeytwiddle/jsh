### B # l # o # a # t # e # d # ! #
## Todo: Offer config.global and config.local config files to ease customization and speed up startup
##       Create ". requiresenv <varname>..." script for checking for existence of neccessary shell environment variables, or exit with error.
##         As well as making dependent shellscripts safe, it will provide some indication to coders as to what inputs a script takes.
##       Further development on dependencies: find dependencies on binaries (=> packages) in PATH too, so that checks may be performed to ensure local sys meets the requirements of each shellscript.  Provide a dselect-like subset chooser.  (". requiresscripts <scriptname>...", ". requiresbins <command>...", ". requirespkgs <package>..." ?)

## Are exits too harsh for a script which is likely to be sourced?
## Do we think it's OK because startj is run by jsh these days?

## Conclusive (?) proof that bash provides nothing to tell us where this script is when it is called with source.
## $_ comes out as previous command (the one called before source!)
# echo "\$\_ = >$_<"
# echo "\$\0 = >$0<"
# echo "\$\* = >$*<"
# env > /tmp/env.out
# set > /tmp/set.out
# chmod a+w /tmp/env.out
# chmod a+w /tmp/set.out

if test "$STARTJ_BLOCK"
then echo "startj blocked ok"
else

	## Dangerous loop if user runs jsh from their .bashrc, so:
	export STARTJ_BLOCK=true
	# test -x "$BASH_BASH" && source "$BASH_BASH"
	## TODO: can only source bashrc if it doesn't contain above
	##       is it possible to start jsh automatically another way
	##       should we grep bashrc to see if suitable?!
	# test -f "$BASH_BASH" &&
	# ! grep "\<jsh\>" "$BASH_BASH" > /dev/null &&
	# ! grep "\<startj\>" "$BASH_BASH" > /dev/null &&
	# . "$BASH_BASH"
	if test "$BASH_BASH"
	then
		if test -f $HOME/.bash_profile
		then . $HOME/.bash_profile
		## Note: this elif (as opposed to fi \n if) assumes .bash_profile always sources .bashrc (like my Debian one)
		elif test -f $HOME/.bashrc
		then . $HOME/.bashrc
		fi
	fi
	## Well maybe we should start sourcing startj again!
	## Even the above checks do not avoid possible inf loops.
	## But anything we do (eg. export NO_MORE_JSHS=true) would prevent the user
	## from recursively running jsh.  (Not that I do that _that_ much!)
	## But so that we can (we need to when a new interactive sh starts, even if started in a parent shell, because aliases still need to be set etc.)
	unset STARTJ_BLOCK

	lookslikejpath () {
		test -f "$1/startj"
	}

	OKTOSTART=true

	## Try to guess the top directory of j install
	## If all below fails, then you should set it youself with export JPATH=...; source $JPATH/startj
	## TODO: Ensure JPATH is an absolute path (jsh may have been called relative to wd)
	if ! lookslikejpath $JPATH
	then
		## TODO: Create a list here then loop it.
		if lookslikejpath "$HOME/j"
		then export JPATH="$HOME/j"
		## This doesn't work: bash cannot see it unless we call startj direct (no source)
		elif lookslikejpath `dirname "$_"`
		then export JPATH=`dirname "$_"`
		## When I tried on Hwi with bash=2.05a-11, it needed $0
		elif lookslikejpath `dirname "$0"`
		then export JPATH=`dirname "$0"`
		else
			echo "startj: Could not find JPATH. Not starting."
			OKTOSTART=
		fi
		# test "$OKTOSTART" && echo "startj: found JPATH=$JPATH"
	fi

	if test $OKTOSTART
	then

		PATHBEFORE="$PATH"
		export PATH="$JPATH/tools:$HOME/bin:$PATH"

		if jwhich jwhich
		then
			echo "Warning: it looks like you have a different jsh in your path, which can be very dangerous (script recursion)."
			echo "$PATH"
			echo "Reverting PATH and not starting."
			export PATH="$PATHBEFORE"
			OKTOSTART=
		fi

	fi

	if test $OKTOSTART
	then

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

			. getmachineinfo

			. joeysaliases
			. cvsinit

			# . dirhistorysetup.bash
			. dirhistorysetup.zsh
			. hwipromptforbash
			. hwipromptforzsh
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

			## What shell are we running?
			## This says SHELL=bash on tao when zsh is run.  zsh only shows in ZSH_NAME !
			## $0 does OK for bash (at least when in .bash_profile!)
			# changed for cygwin, hope solaris and linux r still happy!
			SHELLPS="$$"
			SHORTSHELL=`
				# findjob "$SHELLPS" | # (not on cygwin!)
				ps | grep "$SHELLPS" |
				grep 'sh$' |
				tail -1 |
				sed "s/.* \([^ ]*sh\)$/\1/" |
				sed "s/^-//"
			`
			# echo "shell = $SHORTSHELL"
			## tcsh makes itself known by ${shell} envvar.
			## This says SHELL=bash on tao when zsh is run.  zsh only shows in ZSH_NAME !
			# dunno how we got away without this (needed for cygwin anyway):
			SHORTSHELL=`echo "$SHORTSHELL" | afterlast "/"`

			## METHOD 2:

			## Which flavour shell are we running?
			if test $ZSH_NAME; then
				SHORTSHELL="zsh"
				. zshkeys
			elif test "$BASH"; then
				SHORTSHELL="bash"
				. bashkeys
				shopt -s cdspell checkhash checkwinsize cmdhist dotglob histappend histreedit histverify hostcomplete mailwarn no_empty_cmd_completion shift_verbose
			fi

			. xttitleprompt

		fi # ! simple

	fi # OKTOSTART

fi # STARTJ_BLOCK
