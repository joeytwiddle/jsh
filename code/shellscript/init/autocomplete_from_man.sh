#!/bin/sh
# TO TEST: sometimes the first completion i try to make on a file with " "s in its name appears to break the args?  Is this our fault?

# TODO: Most annoying small bug is that occasionally we want to expand to a
# command not in cwd (e.g. when first call is et/withalldo/...), but most of
# the time we won't want the commands, only what is in cwd.

# TODO: Worse than being slow at the start, is being slow after a reboot.  So we Should keep the cache between reboots.  But we should also maintain it: refresh results once a month, delete unused removed commands.

## BIGGEST TODO: Some of the most obvious commands, eg. cd (which defaults to dirs only),
##               should not perform autocomplete_from_man (which currently overrides defaults for all commands with the same COMPCTL_OPTS).
##               Where can we get a list of ones to avoid doing this on, and go via some other defined default?
##               Really autocomplete_from_man should only be for uncommon commands which don't already default completion rules.
## Simplified: make autocomplete_from_man a fallback from better completion rules.  Find some better completion rules!

## TODO: this should go elsewhere: Does this script have the power to change the user's terminal shell environment?  If so, this technology could be useful, e.g. to reload functions from files when the files are changed, and other things to keep the shell fresh and avoid having to start a subshell or a whole new shell in order to get the latest dev version.

## autocomplete_from_man: Adds to bash or zsh the ability to use tab-completion for the - and -- options of the current command (provided it has a man page installed).
## eg.: source this script with ". ./autocomplete_from_man", then type: tar --<Tab>

## OK now I discovered zsh and bash both come with cool completion scripts (zsh u have to set it up using /usr/share/zsh/4.2.0/functions/Completion/compinstall)
## So if those scripts are on your system, it will source them, and will not bother to setup joeyComplete.
## If you have very old packages then you might not get so much from those scripts.

## CONSIDER: could get filename/type regexps from mimetypes!

## PROBLEM: with zsh at least, is that the command is post-aliased so if eg. the user type "man -"<Tab> then they get options for aliased jman script, not man itself.  (Since at time of writing, alias man=jman)

# jsh-depends: extractpossoptsfrommanpage
# jsh-ext-depends: sed find

## For Kipz; after testing, should be default off, user option to turn it on
# export SHOW_COMMAND_INFO=true

show_command_info () {
	if [ "$ARGS" = "" ] || [ "$ARGS" = - ]
	then
		if [ "$SHOW_COMMAND_INFO" ]
		then
			FOUND=
			if ( builtin "$COMMAND" ) >/dev/null 2>&1 ## This may be running the bash version; zsh's version of builtin may differ
			then printf "%s\n" " `cursegreen;cursebold`[$COMMAND is a shell builtin]`cursenorm`" >&2 ; FOUND=true
			fi
			if alias "$COMMAND" >/dev/null 2>&1
			then printf "%s\n" " `curseyellow`[$COMMAND is an alias to: ` alias "$COMMAND" 2>&1 | afterfirst "=" `]`cursenorm`" >&2 ; FOUND=true
			fi
			if declare -f "$COMMAND" >/dev/null 2>&1
			# if declare -f "$COMMAND" 2>/dev/null | grep . > /dev/null
			then printf "%s\n" " `cursecyan`[$COMMAND is a function: declare -F $COMMAND]`cursenorm`" >&2 ; FOUND=true
			fi
			if [ -e "$JPATH/tools/$COMMAND" ] ## BUG: this line causes "bad pattern" errors in zsh if an uncompleted [ is in the command
			# then printf "%s\n" " `cursered``cursebold`[$COMMAND is a jsh script]`cursenorm`" >&2 ; FOUND=true
			then printf "%s\n" " `cursered``cursebold`[$COMMAND is a jsh script (type jdoc $COMMAND for more info)]`cursenorm`" >&2 ; FOUND=true
			fi
			if [ ! "$FOUND" ]
			then
				# list_commands_in_path | grep "/$COMMAND$" ||
				which "$COMMAND" >/dev/null 2>&1 && printf "%s\n" " `cursegreen;cursebold`[`which "$COMMAND"`]`cursenorm`" >&2 ||
				printf "%s\n" " `cursered`[Could not find $COMMAND]`cursenorm`" >&2
			fi
		fi
	fi
}

## This is expensive, so memo it!  OK that wasn't working, so I disabled the filters below for the moment.
list_commands_in_path () {
		echo "$PATH" | tr ':' '\n' |
		# (EFF) removeduplicatelines |
		while read DIR
		# do [ -r "$DIR" ] && verbosely find "$DIR" -type f -maxdepth 1
		# do [ -r "$DIR" ] && find "$DIR" -maxdepth 1 | filter_list_with test -e | filter_list_with test -x
		do [ -r "$DIR" ] && find "$DIR" -maxdepth 1 # (EFF) disabled until efficient (memoed): | filter_list_with test -e | filter_list_with test -x
		done | sed 's+.*/++' # (EFF) | removeduplicatelines
}

## bash version:
if [ "$BASH" ]
then

	. jgettmpdir -top
	# export BASH_COMPLETION_STORAGE_DIR="$TOPTMP/completion_options-$USER.bash"
	export BASH_COMPLETION_STORAGE_DIR="$HOME/.memocache/bash_completion_options"
	mkdir -p "$BASH_COMPLETION_STORAGE_DIR"
	## TODO: it appears this directory is being created but never used!

	## -g -s removed for odin's older bash

	function joeyComplete {
		COMMAND="$1"
		shift
		ARGS="$*"
		# memo show_command_info ## not working :| (jsh hasn't started?)
		show_command_info
		CURRENT=${COMP_WORDS[COMP_CWORD]}
		WORDS="--help "`
			MEMO_IGNORE_DIR=1 IKNOWIDONTHAVEATTY=1 MEMOFILE="$BASH_COMPLETION_STORAGE_DIR"/"$COMMAND".cached 'memo' -t '1 month' extractpossoptsfrommanpage "$COMMAND"
		`
		## Fix for bug: "it shows you the options, but doesn't let you complete them!" (because it's returning all options, not those which apply to $CURRENT)
		## Also acts as a cache, so future calls are faster:
		complete -W "$WORDS" -a -b -c -d -f -j -k -u "$COMMAND"
		# COMPREPLY=($WORDS)
		COMPREPLY=(`compgen -W "$WORDS" -a -b -c -d -f -j -k -u -- "$CURRENT"`)
	}

	## Since bash only runs completion on named commands, we must go and get the names of all commands in $PATH:
	# (Turned off all alternative completion types until I find a subset which works) ## -g not even possible on odin
	# complete -F joeyComplete `
	complete -a -b -c -d -f -g -j -k -s -u -F joeyComplete `list_commands_in_path`

fi

## zsh version: I could not prevent named matches from continuing on to the glob function, despite use of "-tn".
## So I added an heuristic and simple caching to make it fast.
if [ "$ZSH_NAME" ]
then

	. jgettmpdir -top
	export ZSH_COMPLETION_STORAGE_DIR="$HOME/.memocache/zsh_completion_options"
	mkdir -p "$ZSH_COMPLETION_STORAGE_DIR"

	function joeyComplete {
		read -c COMMAND ARGS
		## Heuristic:
		if [ ! "$ARGS" ]
		then
			reply=
		else
			# memo show_command_info ## not working :| (jsh hasn't started?)
			show_command_info
			## Cache:
			MEMOFILE="$ZSH_COMPLETION_STORAGE_DIR"/"$COMMAND".cached
			if [ ! -f "$MEMOFILE" ] || [ "$REMEMO" ]
			then
				mkdir -p `dirname "$MEMOFILE"` ## This works even if COMMAND is an alias with '/'s in path.
				MEMO_IGNORE_DIR=1 IKNOWIDONTHAVEATTY=1 'memo' extractpossoptsfrommanpage "$COMMAND" > "$MEMOFILE"
			fi
			# AC_CHECK_ALIASES=true
			## Annoying - occurs more than once!
			if [ "$AC_CHECK_ALIASES" ]
			then
				if alias "$COMMAND" >/dev/null 2>&1
				then echo -n "`curseyellow`<$COMMAND is an alias!>`cursenorm`" >/dev/stderr
				fi
			fi
			## I think these single brackets mean a string:
			reply=(--help `cat "$MEMOFILE"`)
			## Ne marche pas: compctl -f -c -u -r -k "($reply)" -H 0 '' "$COMMAND" -tn
		fi
	}

	# COMPCTL_OPTS="-f -c -u -r -K" ## I don't appear to be able to pass this variable as options.  Crazy builtin I guess. :-/
	compctl -f -c -u -r -K joeyComplete "*" -tn
	## History made directory /s not work and was in general quite annoying for me:
	# -H 0 '' 

fi
