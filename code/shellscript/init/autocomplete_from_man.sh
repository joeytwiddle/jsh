## Extracts the options for command-line programs from man pages, and adds them to the shell completion rules.
## Works with bash and zsh.
## eg.: source this script then type: tar --<Tab>

## To clear [bash]: complete -r

## TODO: cache rules so they may be loaded faster (means generating them as stream?)
## CONSIDER: save completions rules in global file rather than bloating every shell; use completion function and grep to retrieve them when needed



# ## Method 1: pre-generate rules for selected commands
# 
# ## TODO: obtain more commands from shell-history
# COMMANDS="ls man tar ssh rsync mplayer btdownloadcurses grep diff cvs svn dpkg apt-get rpm wget lynx java jar $*"
# if [ "$ZSH_NAME" ] ## TODO: convert the bash string to a zsh array!
# then COMMANDS=(ls man tar ssh rsync mplayer btdownloadcurses grep diff cvs svn dpkg apt-get rpm wget lynx java jar $*)
# fi
# 
# for COMMAND in $COMMANDS
# do
# 
	# echo -n "$COMMAND " >&2
# 
	# MANOPTS="--help "`memo extractpossoptsfrommanpage "$COMMAND" 2>/dev/null | tr '\n' ' '`
# 
	# if [ "$ZSH_NAME" ]
	# then
		# compctl -tn -f -c -u -r -k "($MANOPTS)" -H 0 '' $COMMAND ## -f files -c commands -u users -r running jobs +-H last_resort_history -k man_options
	# elif [ "$BASH" ]
	# then
		# complete -W "$MANOPTS" $COMMAND
	# fi
# 
# done
# 
# echo >&2



## Method 2: generate for any command on the fly

## zsh version: works on any command on the fly.  Jsh memoing was too slow, and I could not get non-glob matches with -tn to avoid this glob search.
## So instead I added an heuristic and simple caching inline to make it fast.
if [ "$ZSH_NAME" ]
then

	mkdir /tmp/completion_options

	function joeyComplete {
		read -c COMMAND ARGS
		## Heuristic:
		if [ ! "$ARGS" ]
		then
			reply=""
		else
			## Cache:
			MEMOFILE=/tmp/completion_options/"$COMMAND".cached
			if [ ! -f "$MEMOFILE" ] || [ "$REMEMO" ]
			then extractpossoptsfrommanpage "$COMMAND" 2>/dev/null | tr '\n' ' ' > "$MEMOFILE"
			fi
			reply=(--help `cat "$MEMOFILE"`)
		fi
	}

	compctl -f -c -u -r -K joeyComplete -H 0 '' "*" -tn

fi

## bash version: looking at man page, I cannot get it to run on any command, only on those I list
## BUG: also, it's broken: it shows you the options, but doesn't let you complete them!  I suspect the reply array.
if [ "$BASH" ]
then

	function joeyComplete {
		COMMAND="$1"
		COMPREPLY=(--help `memo extractpossoptsfrommanpage "$COMMAND" 2>/dev/null | tr '\n' ' '`)
	}

	complete -F joeyComplete cat patch make

fi

