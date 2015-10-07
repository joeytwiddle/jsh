# @sourceme

# When PROMPT is expanded, also expand any ${...} or $(...) inside it.
# Currently this is only needed for GIT_AWARE_PROMPT, but we do it always for consistency.
setopt PROMPT_SUBST

# Set the color for the command line editor.
#zle_highlight=( default:bg=black,fg=white )

if [[ "$USER" = joey ]] && [[ -z "$SSH_CONNECTION" ]] && false #[ "$SHORTHOST" = hwi ] || [[ "$SHORTHOST" = tomato ]]
then

		## By far the coolest prompt
		export PROMPT="%{[01;31m%}%? %{[00;32m%}%~/%{[00m%} "
		# export RPROMPT="%{ %}%{[00m%}%n@%{[00m%}%m %{[00;36m%}%* %{[00m%}(%{[00;35m%}%h%{[00m%}:%{[00;33m%}%l%{[00m%})%{m%}"
		# The trick in the line above to push RPROMPT one char right, has a problem in gnome-terminal, in which case use the line below
		export RPROMPT="%{[00m%}%n@%{[00m%}%m %{[00;36m%}%* %{[00m%}(%{[00;35m%}%h%{[00m%}:%{[00;33m%}%l%{[00m%})"
		# bright white:
		# export PROMPT="%{[01;31m%}%? %{[00;32m%}%~/%{[01m %} "
		# export RPROMPT="%{[00m%}%n@%{[00m%}%m %{[00;36m%}%* %{[00m%}(%{[00;35m%}%h%{[00m%}:%{[00;33m%}%l%{[01m%})"
		# space escaped:
		# export PROMPT="%{[01;31m%}%? %{[00;32m%}%~/ %{[01m%}%{ %}"
		# export RPROMPT="%{[00m%}%n@%{[00m%}%m %{[00;36m%}%* %{[00m%}(%{[00;35m%}%h%{[00m%}:%{[00;33m%}%l%{[00m%})"

		## Argh, I need to know if I'm in a chroot system!  Peeking at 'mount' can do this.

elif test "$USER" = root
then

		## HEAD is to inject our own xttitleprompt
		# HEAD="%{[00;33m%}>%{[01;31m%}!%{[00;33m%}DANGER%{[01;31m%}!%{[00;33m%}<"
		# HEAD="%{[00;33m%}>%{[01;31m%}!%{[00;33m%}ROOT%{[01;31m%}!%{[00;33m%}<"
		# HEAD="%{[01;31m%}>%{[00;33m%}ROOT%{[01;31m%}<"
		# declare -f swd >/dev/null && HEAD="" || ## Check if we are using xttitleprompt, and if so do not embed xterm title escape block.
		HEAD="%{[00;33m%}>%{[01;31m%}ROOT%{[00;33m%}<"
		# HEAD="ROOT"
		export PROMPT="%{[01;31m%}$HEAD %{[01;33m%}%? %{[00;36m%}%~/%{[01;31m%} "
		export RPROMPT="$RPROMPT%{[00;37m%}"

else

		#export PROMPT="%{[00;36m%}%n%{[00m%}@%{[00;36m%}%m%{[00m%}:%{[00;32m%}%~/%{[00m%} "
		# Experimenting with filled background (to help prompts stand out from process output)
		#export PROMPT="%{[47;34m`cursebold`%}%n%{[47;30m%}@%{[47;34m`cursebold`%}%m%{[00m%} %{[00;32m%}%~/%{[00m%} "
		#export PROMPT="%{[47;34m`cursebold`%}%n%{[47;30m%}@%{[47;34m`cursebold`%}%m%{[00m%}%{[47;32m%} %~/%{[00m%} "
		#export PROMPT="%{[47;34m`cursebold`%}%n%{[47;30m%}@%{[47;34m`cursebold`%}%m%{[00m%}%{[42;30m%} %~/%{[00m%} "
		#export PROMPT="%{[47;34m`cursebold`%}%n%{[47;30m%}@%{[47;34m`cursebold`%}%m%{[00m%}%{[44;32m[01m%} %~/%{[00m%} "
		#export PROMPT="%{[42;30m%}%n%{[42;30m%}@%{[42;30m%}%m%{[00m%}%{[44;32m[01m%} %~/%{[00m%} "
		# 40 = black background, 44 = blue background
		bgcol=40
		## Background extends beneath the current directory
		#export PROMPT="%{[${bgcol};36m%}%n%{[${bgcol};37m%}@%{[${bgcol};36m%}%m %{[${bgcol};32m`cursebold`%}%~/%{[00m%} "
		## Background only lies beneath the user@hostname
		export PROMPT="%{[${bgcol};36m%}%n%{[${bgcol};37m%}@%{[${bgcol};36m%}%m%{[00m%} %{[00;32m%}%~/%{[00m%} "

		export RPROMPT="%{[0%?;30m%}[%{[0%?;3%?m%}err %?%{[0%?;30m%}]%{[00;35m%}%h%{[00m%}%{[00m%}(%{[00;36m%}%*%{[00m%})%{[00;33m%}%l%{[00m%}"
		## My prefered colours for Unix:
		# export PROMPT="%{[00;36m%}%n%{[00m%}@%{[00;36m%}%m%{[00m%}:%{[00;33m%}%~/%{[00m %} "
		# # export RPROMPT="%{[00;31m%}%?%{[00m%}:%{[00;35m%}%h%{[00m%}%{[00m%}(%{[00;36m%}%*%{[00m%})%{[00;33m%}%l%{[00m%}"
		# export RPROMPT="%{[0%?;30m%}[%{[00;3%?m%}err %?%{[0%?;30m%}]%{[00;35m%}%h%{[00m%}%{[00m%}(%{[00;36m%}%*%{[00m%})%{[00;33m%}%l%{[00m%}"
fi

if true # has_battery
then
	get_power_stats_zsh_hook() {
		power_stats=$(get_power_stats -mini | sed 's+%+%%+g')
	}
	autoload add-zsh-hook
	add-zsh-hook precmd get_power_stats_zsh_hook

	RPROMPT=$(printf "%s" "$RPROMPT" | sed "s+%l+%l%{[00m%}:%{[00;36m%}\$power_stats+")
fi

## This is a good indicator if user got here via ssh:
if [ -n "$SSH_CONNECTION" ]
then
	PROMPT="%{[01;33m%}<$USER@$SHORTHOST> $PROMPT"
	export XTTITLE_PRESTRING="<$USER@$SHORTHOST> $XTTITLE_PRESTRING"
fi

if declare -f find_git_branch >/dev/null
then
	local GIT_AWARE_PROMPT="\%{`cursemagenta;cursebold`\%}\$git_branch\%{`cursegreen``cursebold`\%}\$git_ahead_mark\$git_ahead_count\%{`cursered``cursebold`\%}\$git_behind_mark\$git_behind_count\%{`curseyellow``cursebold`\%}\$git_stash_mark\%{`curseyellow`\%}\$git_dirty\$git_dirty_count\%{`cursecyan`\%}\$git_staged_mark\$git_staged_count\%{`curseblue`\%}\$git_unknown_mark\$git_unknown_count"
	# \%{`cursenorm`\%}$
	# Append these extras after the existing %{color}~/ part of the prompt
	PROMPT=$(printf "%s" "$PROMPT" | sed "s+\(%{\([^%]*%[^}]\)*[^%]*%} *%~/*\)+\1$GIT_AWARE_PROMPT+g")
	# Whenever precmd is called, also run find_git_branch
	# add-zsh-hook, which we load from zshcontrib, is just used to help us arrange the precmd array
	autoload add-zsh-hook
	add-zsh-hook precmd find_git_branch
	add-zsh-hook precmd find_git_dirty
	add-zsh-hook precmd find_git_ahead_behind
	add-zsh-hook precmd find_git_stash_status
fi

# if test "$SHLVL" -gt 3
# then PROMPT="($SHLVL) $PROMPT"
# fi

# if [ "$TERM" = screen ]
if [ -n "$STY" ]
then
	SCREEN_NAME=`echo "$STY" | afterfirst '\.'`
	# test "$SCREEN_NAME" || SCREEN_NAME=screen
	PROMPT="[$SCREEN_NAME$WINDOW] $PROMPT"
fi

## for zsh -x debugging (bad for bash though!)
# See section "SIMPLE PROMPT ESCAPES"
# %L is shell-level ($SHLVL, depth of child shells)
# %? is the previous exit code
# PS4="%{[00;35m%}[%{[00;31m%}%N[00;35m%}]%{[00;33m%}%_%{%{[00m%}%% "
# ## Outputs the following format: [script_name]exec_trace% command args
# PS4="%{`cursemagenta`%}[%{`cursered`%}%1N%{`cursemagenta`%}]%{`curseyellow`%}%_%{`cursenorm`%}%% "
## Outputs the following format: (exit_code)shell_level/dir/[script_name]exec_trace% command args
# PS4="(%?)%L%c%{`cursemagenta`%}[%{`cursered``cursebold`%}%1N:%i%{`cursemagenta`%}]%{`curseyellow`%}%_%{`cursenorm`%}%# "
PS4="%{`cursemagenta`%}+%{`curseblue`%}%L%{`cursemagenta`%}?%{`curseblue`%}%?%{`cursemagenta`%}|%{`cursegreen`%}%c%{`cursemagenta`%}|%{`cursered``cursebold`%}%1N:%i%{`cursemagenta`%}|%{`curseyellow`%}%_%{`cursemagenta`%}%{`cursemagenta`%}>%{`cursenorm`%} "

## TODO: Should really go in bash's .bash_profile (or is it .rc?), so that it is invoked when user types: bash -x something.sh
##       At the moment that calls bash with zsh's PS4, which makes a horrid mess if it gets the zsh PS4 above.
##       Hmmm I tried putting this PS4 in .bashrc and .bash_profile but it didn't work =/
##       Maybe instead we can put zsh's PS4 above in .zshrc ? ^^
## So for now I'm defaulting to a bash-compatible PS4:
# export PS4="\[\033[01;31m\]=$$=\[\033[00m\]"
# export PS4='\['"`cursered`"'\]'"=="'\['"`cursenorm`"'\]'"
# export PS4="+[bash] "
# export PS4="+\[`cursegreen`\]\W\[`cursenorm`\]\$ "
# export PS4="+\[`cursegreen`\]\W\[`cursenorm`\][\[`cursered;cursebold`\]\s\[`cursenorm`\]]\$ "
# \[`cursemagenta`\]
export PS4="\[`curseblue`\]+[\[`cursered;cursebold`\]\s\[`cursemagenta`\]]\[`cursegreen`\]\W\[`cursenorm`\]\[`cursenorm`\]# "

