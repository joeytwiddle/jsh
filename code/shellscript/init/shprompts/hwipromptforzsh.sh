#/bin/sh

# Hwi:
case `hostname` in

	hwi)
		## By far the coolest prompt
		export PROMPT="%{[01;31m%}%? %{[00;32m%}%~/%{[00m%}%{%} "
		# export RPROMPT="%{ %}%{[00m%}%n@%{[00m%}%m %{[00;36m%}%* %{[00m%}(%{[00;35m%}%h%{[00m%}:%{[00;33m%}%l%{[00m%})%{m%}"
		# The trick in the line above to push RPROMPT one char right, has a problem in gnome-terminal, in which case use the line below
		export RPROMPT="%{[00m%}%n@%{[00m%}%m %{[00;36m%}%* %{[00m%}(%{[00;35m%}%h%{[00m%}:%{[00;33m%}%l%{[00m%})"
		# bright white:
		# export PROMPT="%{[01;31m%}%? %{[00;32m%}%~/%{[01m %} "
		# export RPROMPT="%{[00m%}%n@%{[00m%}%m %{[00;36m%}%* %{[00m%}(%{[00;35m%}%h%{[00m%}:%{[00;33m%}%l%{[01m%})"
		# space escaped:
		# export PROMPT="%{[01;31m%}%? %{[00;32m%}%~/ %{[01m%}%{ %}"
		# export RPROMPT="%{[00m%}%n@%{[00m%}%m %{[00;36m%}%* %{[00m%}(%{[00;35m%}%h%{[00m%}:%{[00;33m%}%l%{[00m%})"
		if test "$USER" = root || test "$USERNAME" = root
		then
			# HEAD="%{[00;33m%}>%{[01;31m%}!%{[00;33m%}DANGER%{[01;31m%}!%{[00;33m%}<"
			# HEAD="%{[00;33m%}>%{[01;31m%}!%{[00;33m%}ROOT%{[01;31m%}!%{[00;33m%}<"
			# HEAD="%{[01;31m%}>%{[00;33m%}ROOT%{[01;31m%}<"
			HEAD="%{[00;33m%}>%{[01;31m%}ROOT%{[00;33m%}<"
			# HEAD="ROOT"
			export PROMPT="%{[01;31m%}$HEAD %{[01;33m%}%? %{[00;36m%}%~/%{[01;31m%} "
			export RPROMPT="$RPROMPT%{[00;32m%}"
		fi
	;;

	*)
		# For scp:
		export PROMPT="%{[00;36m%}%n%{[00m%}@%{[00;36m%}%m%{[00m%}:%{[00;33m%}%~/%{[00m %} "
		# export RPROMPT="%{[00;31m%}%?%{[00m%}:%{[00;35m%}%h%{[00m%}%{[00m%}(%{[00;36m%}%*%{[00m%})%{[00;33m%}%l%{[00m%}"
		export RPROMPT="%{[0%?;30m%}(%{[00;3%?m%}err %?%{[0%?;30m%}) %{[00;35m%}%h%{[00m%}%{[00m%}(%{[00;36m%}%*%{[00m%})%{[00;33m%}%l%{[00m%}"
	;;

esac

if test "$SCREEN_RUNNING"
then export PROMPT="[screen] $PROMPT"
fi

## for sh -x debugging
export PS4="%{[00;35m%}[%{[00;31m%}%N[00;35m%}]%{[00;33m%}%_%{%{[00m%}%% "
