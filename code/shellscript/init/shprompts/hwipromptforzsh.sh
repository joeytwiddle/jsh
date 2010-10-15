#!/bin/sh
#/bin/sh

if test "$USER" = joey && test "$SHORTHOST" = hwi
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

elif test "$USER" = root
then

		## HEAD is for xttitleprompt
		# HEAD="%{[00;33m%}>%{[01;31m%}!%{[00;33m%}DANGER%{[01;31m%}!%{[00;33m%}<"
		# HEAD="%{[00;33m%}>%{[01;31m%}!%{[00;33m%}ROOT%{[01;31m%}!%{[00;33m%}<"
		# HEAD="%{[01;31m%}>%{[00;33m%}ROOT%{[01;31m%}<"
		# declare -f swd >/dev/null && HEAD="" || ## Check if we are using xttitleprompt, and if so do not embed xterm title escape block.
		HEAD="%{[00;33m%}>%{[01;31m%}ROOT%{[00;33m%}<"
		# HEAD="ROOT"
		export PROMPT="%{[01;31m%}$HEAD %{[01;33m%}%? %{[00;36m%}%~/%{[01;31m%} "
		export RPROMPT="$RPROMPT%{[00;32m%}"

else

		export PROMPT="%{[00;36m%}%n%{[00m%}@%{[00;36m%}%m%{[00m%}:%{[00;32m%}%~/%{[00m%} "
		export RPROMPT="%{[0%?;30m%}[%{[0%?;3%?m%}err %?%{[0%?;30m%}]%{[00;35m%}%h%{[00m%}%{[00m%}(%{[00;36m%}%*%{[00m%})%{[00;33m%}%l%{[00m%}"
		## My prefered colours for Unix:
		# export PROMPT="%{[00;36m%}%n%{[00m%}@%{[00;36m%}%m%{[00m%}:%{[00;33m%}%~/%{[00m %} "
		# # export RPROMPT="%{[00;31m%}%?%{[00m%}:%{[00;35m%}%h%{[00m%}%{[00m%}(%{[00;36m%}%*%{[00m%})%{[00;33m%}%l%{[00m%}"
		# export RPROMPT="%{[0%?;30m%}[%{[00;3%?m%}err %?%{[0%?;30m%}]%{[00;35m%}%h%{[00m%}%{[00m%}(%{[00;36m%}%*%{[00m%})%{[00;33m%}%l%{[00m%}"

fi

# if test "$SHLVL" -gt 3
# then PROMPT="($SHLVL) $PROMPT"
# fi

# if [ "$TERM" = screen ]
if [ "$STY" ]
then
	SCREEN_NAME=`echo "$STY" | afterfirst '\.'`
	# test "$SCREEN_NAME" || SCREEN_NAME=screen
	PROMPT="[$SCREEN_NAME$WINDOW] $PROMPT"
fi

## for zsh -x debugging (bad for bash though!)
# export PS4="%{[00;35m%}[%{[00;31m%}%N[00;35m%}]%{[00;33m%}%_%{%{[00m%}%% "
# ## Outputs the following format: [script_name]exec_trace% command args
# export PS4="%{`cursemagenta`%}[%{`cursered`%}%1N%{`cursemagenta`%}]%{`curseyellow`%}%_%{`cursenorm`%}%% "
## Outputs the following format: (exit_code)shell_level/dir/[script_name]exec_trace% command args
# export PS4="(%?)%L%c%{`cursemagenta`%}[%{`cursered``cursebold`%}%1N:%i%{`cursemagenta`%}]%{`curseyellow`%}%_%{`cursenorm`%}%# "
export PS4="(%?)%L%{`cursegreen`$}%c%{`cursemagenta`%}[%{`cursered``cursebold`%}%1N:%i%{`cursemagenta`%}]%{`curseyellow`%}%_%{`cursenorm`%}%# "

## TODO: Should really go in bash's .bash_profile (or is it .rc?), so that it is invoked when user types: sh -x something.sh
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

