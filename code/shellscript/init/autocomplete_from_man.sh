## autocomplete_from_man: Adds to bash or zsh the ability to use tab-completion for the - and -- options of the current command (provided it has a man page installed).
## eg.: source this script with ". ./autocomplete_from_man", then type: tar --<Tab>

# jsh-depends: extractpossoptsfrommanpage
# jsh-ext-depends: sed find

## bash version:
if [ "$BASH" ]
then

	function joeyComplete {
		COMMAND="$1"
		ARGS="$1"
		WORDS="--help "`extractpossoptsfrommanpage "$COMMAND"`
		## Fix for bug: "it shows you the options, but doesn't let you complete them!"  Also acts as a cache.
		complete -W "$WORDS" "$COMMAND"
		COMPREPLY=($WORDS)
	}

	## Since bash only runs completion on named commands, we must go and get the names of all commands in $PATH:
	complete -F joeyComplete `
		echo "$PATH" | tr ':' '\n' |
		while read DIR
		do find "$DIR" -type f -maxdepth 1
		done | sed 's+.*/++'
	`

fi

## zsh version: I could not prevent named matches from continuing on to the glob function, despite use of "-tn".
## So I added an heuristic and simple caching to make it fast.
if [ "$ZSH_NAME" ]
then

	mkdir -p /tmp/completion_options

	function joeyComplete {
		read -c COMMAND ARGS
		## Heuristic:
		if [ ! "$ARGS" ]
		then
			reply=
		else
			## Cache:
			MEMOFILE=/tmp/completion_options/"$COMMAND".cached
			if [ ! -f "$MEMOFILE" ] || [ "$REMEMO" ]
			then extractpossoptsfrommanpage "$COMMAND" > "$MEMOFILE"
			fi
			reply=(--help `cat "$MEMOFILE"`)
			## Ne marche pas: compctl -f -c -u -r -k "($reply)" -H 0 '' "$COMMAND" -tn
		fi
	}

	compctl -f -c -u -r -K joeyComplete -H 0 '' "*" -tn

fi
