## autocomplete_from_man: Adds to bash or zsh the ability to use tab-completion for the - and -- options of the current command (provided it has a man page installed).
## eg.: source this script with ". ./autocomplete_from_man", then type: tar --<Tab>

## OK now I discovered zsh and bash both come with cool completion scripts (zsh u have to set it up using /usr/share/zsh/4.2.0/functions/Completion/compinstall)
## So if those scripts are on your system, it will source them, and will not bother to setup joeyComplete.
## If you have very old packages then you might not get so much from those scripts.

## CONSIDER: could get filename/type regexps from mimetypes!

## PROBLEM: with zsh at least, is that the command is post-aliased so if eg. the user type "man -"<Tab> then they get options for aliased jman script, not man itself.  (Since at time of writing, alias man=jman)

# jsh-depends: extractpossoptsfrommanpage
# jsh-ext-depends: sed find

## bash version:
if [ "$BASH" ]
then

	## -g -s removed for odin's older bash

	function joeyComplete {
		COMMAND="$1"
		CURRENT=${COMP_WORDS[COMP_CWORD]}
		WORDS="--help "`
			extractpossoptsfrommanpage "$COMMAND"
		`
		## Fix for bug: "it shows you the options, but doesn't let you complete them!" (because it's returning all options, not those which apply to $CURRENT)
		## Also acts as a cache, so future calls are faster:
		complete -W "$WORDS" -a -b -c -d -f -j -k -u "$COMMAND"
		# COMPREPLY=($WORDS)
		COMPREPLY=(`compgen -W "$WORDS" -a -b -c -d -f -j -k -u -- "$CURRENT"`)
	}

	## Since bash only runs completion on named commands, we must go and get the names of all commands in $PATH:
	# (Turned off all alternative completion types until I find a subset which works) ## -g not even possible on odin
	# complete -a -b -c -d -f -g -j -k -s -u -F joeyComplete `
	complete -F joeyComplete `
		echo "$PATH" | tr ':' '\n' |
		while read DIR
		do [ -r "$DIR" ] && find "$DIR" -type f -maxdepth 1
		done | sed 's+.*/++'
	`

fi

## zsh version: I could not prevent named matches from continuing on to the glob function, despite use of "-tn".
## So I added an heuristic and simple caching to make it fast.
if [ "$ZSH_NAME" ]
then

	function joeyComplete {
		read -c COMMAND ARGS
		## Heuristic:
		if [ ! "$ARGS" ]
		then
			reply=
		else
			## Cache:
			MEMOFILE=/tmp/completion_options-$USER/"$COMMAND".cached
			if [ ! -f "$MEMOFILE" ] || [ "$REMEMO" ]
			then
				mkdir -p `dirname "$MEMOFILE"` ## This works even if COMMAND is an alias with '/'s in path.
				extractpossoptsfrommanpage "$COMMAND" > "$MEMOFILE"
			fi
			reply=(--help `cat "$MEMOFILE"`)
			## Ne marche pas: compctl -f -c -u -r -k "($reply)" -H 0 '' "$COMMAND" -tn
		fi
	}

	compctl -f -c -u -r -K joeyComplete "*" -tn
	## History made directory /s not work and was in general quite annoying for me:
	# -H 0 '' 

fi
