### zsh commandline completion based on output of recent (latest) command

# How it works:
# We add 'record-log ' before every command to be executed.
# So in fact record-log is executed.  It then runs the command, but it sends output to a file.
# Later, tab-completion can read this file to obtain useful words.

# You can enable ALWAYS_RECORD_OUTPUT_COMPLETION to get it to automatically record the output of commands.
# But it is quite disruptive at the moment, so a friendlier alternative is to put `record-log ` at the beginning of a command before running it.  The output of the command will be stored and you will later be able to perform completion on its words.

# ISSUES:
# - Only applies to the commands before a '|' I believe.
# - Does not work on aliases.
# - History gets polluted with record-log appended to commands
# - The use of tee forces things like man to simply cat the file, instead of providing the interactive pager
# - Completion doesn't work on all commands.  (I have had trouble with `git log` and aliases to it.  `l` and `echo` always seem to work.)

# For the bash version, we may be able to use the "DEBUG trap": http://askubuntu.com/questions/22233/always-prompt-the-user-before-executing-a-command-in-the-shell#22256
# This page has a nice example of a history search under the section "Programmable Completion": http://www.cl.cam.ac.uk/local/sys/unix/applications/bash/
# I found that through this page: http://unix.stackexchange.com/questions/61871/can-any-shell-do-argument-level-interactive-search

RUNTIME_FILE_PREFIX="/tmp/joey-output-completion.$$"

record-log() {
	# We cannot use eval here, it doesn't process aliases.
	"$@" | tee "$RUNTIME_FILE_PREFIX".output
	# Process the output now, rather than once each completion
	cat "$RUNTIME_FILE_PREFIX".output | striptermchars > "$RUNTIME_FILE_PREFIX".clean_output
	grep -o "[^ ]*" "$RUNTIME_FILE_PREFIX".clean_output > "$RUNTIME_FILE_PREFIX".output_completions
}

add-log-recorder() {
	# Aliases and functions and shell-builtins (like cd and source) might affect the shell session.
	# But our recorder causes the command to be run in a child shell.
	# So we only record a log if the command is going to run an executable file.
	local first_arg="${BUFFER% *}"
	local which_output="$(which $first_arg)"
	# But many aliases will run executables, so let's allow them for now.
	if alias "$first_arg" >/dev/null
	then local is_an_alias=1
	fi
	# Except for some of my crucial alaises which require local execution
	case "$first_arg" in
		cd|b|f)
			local is_an_alias=
		;;
	esac
	if [ -n "$is_an_alias" ] || ( [ -f "$which_output" ] && [ -x "$which_output" ] )
	then
		[[ $BUFFER = record-log* ]] || BUFFER="record-log $BUFFER"
	fi
	zle .$WIDGET "$@"
}

# Tell zsh to run our add-log-recorder function before executing a command, which gives it the opportunity to modify the command.
# At the moment this is a little disruptive, so I don't enable it by default.
if [ -n "$ALWAYS_RECORD_OUTPUT_COMPLETION" ]
then
	zle -N accept-line add-log-recorder
fi

alias log=record-log
alias record=record-log
alias copy=record-log
alias ccopy=record-log
alias clog=record-log
alias crec=record-log

output-completion() {
	read -c COMMAND ARGS
	## Heuristic:
	if [ -z "$ARGS" ]
	then
		echo -n "[skip]"
		reply=
	else
		# This stops the cat from throwing errors if no completions were generated.
		#touch "$RUNTIME_FILE_PREFIX".output_completions
		reply=( $(cat "$RUNTIME_FILE_PREFIX".output_completions) )
	fi
}

# It might be nice if we could complete whole filenames from recent output, instead of being forced to step through each folder with Tab.  We need to mute the default folder/file completion.
# I tried removing -n but still found completions were completing based on the filesystem nodes.
compctl -f -c -u -r -K output-completion "*" -tn
# Anyway there is room for improvement here, not least moving to |zsh-compsys|
