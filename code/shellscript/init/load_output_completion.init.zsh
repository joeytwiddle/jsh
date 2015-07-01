RUNTIME_FILE_PREFIX="/tmp/joey-output-completion.$$"

record-log() {
	"$@" | tee "$RUNTIME_FILE_PREFIX".output
	# Process the output now, rather than once each completion
	cat "$RUNTIME_FILE_PREFIX".output | striptermchars > "$RUNTIME_FILE_PREFIX".clean_output
	grep -o "[^ ]*" "$RUNTIME_FILE_PREFIX".clean_output > "$RUNTIME_FILE_PREFIX".output_completions
}

add-log-recorder() {
	# Aliases and functions and shell-builtins (like cd and source) might affect the shell session.
	# So we only record a log if the command is going to run an executable file.
	local first_arg="${BUFFER% *}"
	which_output="$(which $first_arg)"
	if [ -f "$which_output" ] && [ -x "$which_output" ] #&& [ ! "$first_arg" = cd ]
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
		#MEMOFILE="$ZSH_COMPLETION_STORAGE_DIR"/"$COMMAND".cached
		## The single brackets means an array
		reply=( "--help" $(cat "$RUNTIME_FILE_PREFIX".output_completions) )
	fi
}

compctl -f -c -u -r -K output-completion "*" -tn
