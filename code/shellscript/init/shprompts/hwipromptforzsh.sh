#/bin/sh

# Hwi:
if startswith `hostname` hwi; then

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

else

# For scp:
export PROMPT="%{[00;36m%}%n%{[00m%}@%{[00;36m%}%m%{[00m%}:%{[00;33m%}%~/%{[00m %} "
# export RPROMPT="%{[00;31m%}%?%{[00m%}:%{[00;35m%}%h%{[00m%}%{[00m%}(%{[00;36m%}%*%{[00m%})%{[00;33m%}%l%{[00m%}"
export RPROMPT="%{[0%?;30m%}(%{[00;3%?m%}err %?%{[0%?;30m%}) %{[00;35m%}%h%{[00m%}%{[00m%}(%{[00;36m%}%*%{[00m%})%{[00;33m%}%l%{[00m%}"

fi
