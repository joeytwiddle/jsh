### zsh commandline completion based on output of recent (latest) command

# ISSUES:
# - History gets polluted with record-log appended to commands
# - tee forces things like man to simply cat the file, instead of providing the interactive pager

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

zle -N accept-line add-log-recorder

output-completion() {
	read -c COMMAND ARGS
	## Heuristic:
	if [ -z "$ARGS" ]
	then
		reply=
	else
		# This stops the cat from throwing errors if no completions were generated.
		#touch "$RUNTIME_FILE_PREFIX".output_completions
		reply=( $(cat "$RUNTIME_FILE_PREFIX".output_completions) )
	fi
}

compctl -f -c -u -r -K output-completion "*" -tn
