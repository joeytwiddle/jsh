## autocomplete_from_man: Adds to bash or zsh the ability to use tab-completion for the - and -- options of the current command (provided it has a man page installed).
## eg.: source this script with ". ./autocomplete_from_man", then type: tar --<Tab>

## OK now I discovered zsh and bash both come with cool completion scripts (zsh u have to set it up using /usr/share/zsh/4.2.0/functions/Completion/compinstall)
## So if those scripts are on your system, it will source them, and will not bother to setup joeyComplete.
## If you have very old packages then you might not get so much from those scripts.

## CONSIDER: could get filename/type regexps from mimetypes!

# jsh-depends: extractpossoptsfrommanpage
# jsh-ext-depends: sed find

## bash version:
if [ "$BASH" ]
then

	if [	-f /etc/bash_completion ]
	then . /etc/bash_completion
	else

		function joeyComplete {
			COMMAND="$1"
			CURRENT=${COMP_WORDS[COMP_CWORD]}
			WORDS="--help "`
				extractpossoptsfrommanpage "$COMMAND"
			`
			## Fix for bug: "it shows you the options, but doesn't let you complete them!" (because it's returning all options, not those which apply to $CURRENT)
			## Also acts as a cache, so future calls are faster:
			complete -W "$WORDS" -a -b -c -d -f -g -j -k -s -u "$COMMAND"
			# COMPREPLY=($WORDS)
			COMPREPLY=(`compgen -W "$WORDS" -a -b -c -d -f -g -j -k -s -u -- "$CURRENT"`)
		}
	
		## Since bash only runs completion on named commands, we must go and get the names of all commands in $PATH:
		# complete -a -b -c -d -f -g -j -k -s -u -F joeyComplete `
		complete -F joeyComplete `
			echo "$PATH" | tr ':' '\n' |
			while read DIR
			do find "$DIR" -type f -maxdepth 1
			done | sed 's+.*/++'
		`

		# ### This is a dodgy attempt to /add/ joeyComplete to existing rules (eg. /etc/bash_completion), rather than override the existing rule.
		# ## At present I think it doesn't work because ALREADYDEFINED already contains a -F, so joeyComplete gets ignored.
		# ## Anyway, it all seems unneccessary, because bash comes with a cool completion script!
		# ( echo "$PATH" | tr ':' '\n' |
		# while read DIR
		# do find "$DIR" -type f -maxdepth 1
		# done | sed 's+.*/++'; echo tar; echo bunzip2) | tail -20 | removeduplicatelines |
		# while read COMMAND
		# do
			# ALREADYDEFINED=`complete -p "$COMMAND" 2>/dev/null | beforelast ' '`
			# if [ "$ALREADYDEFINED" ]
			# then
				# # echo $ALREADYDEFINED -F joeyComplete "$COMMAND"
				# $ALREADYDEFINED -F joeyComplete "$COMMAND"
			# else
				# complete -F joeyComplete "$COMMAND"
			# fi
		# done

	fi

fi

## zsh version: I could not prevent named matches from continuing on to the glob function, despite use of "-tn".
## So I added an heuristic and simple caching to make it fast.
if [ "$ZSH_NAME" ]
then

	if [ -f $HOME/.zsh_completion_rules ]
	then . $HOME/.zsh_completion_rules
	else

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

fi
