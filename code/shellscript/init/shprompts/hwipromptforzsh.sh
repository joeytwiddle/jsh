#/bin/sh

# Hwi:
export PROMPT="%{[01;31m%}%? %{[00;32m%}%~/%{[00;37m%}%{%} "
export RPROMPT="%{ %}%{[00;37m%}%n@%{[00;37m%}%m %{[00;36m%}%* %{[00;37m%}(%{[00;35m%}%h%{[00;37m%}:%{[00;33m%}%l%{[00m%})%{m%}"
# The trick in the line above to push RPROMPT one char right, has a problem in gnome-terminal, in which case use the line below
# export RPROMPT="%{[00;37m%}%n@%{[00;37m%}%m %{[00;36m%}%* %{[00;37m%}(%{[00;35m%}%h%{[00;37m%}:%{[00;33m%}%l%{[00m%})"
# bright white:
# export PROMPT="%{[01;31m%}%? %{[00;32m%}%~/%{[01;37m %} "
# export RPROMPT="%{[00;37m%}%n@%{[00;37m%}%m %{[00;36m%}%* %{[00;37m%}(%{[00;35m%}%h%{[00;37m%}:%{[00;33m%}%l%{[01;37m%})"
# space escaped:
# export PROMPT="%{[01;31m%}%? %{[00;32m%}%~/ %{[01;37m%}%{ %}"
# export RPROMPT="%{[00;37m%}%n@%{[00;37m%}%m %{[00;36m%}%* %{[00;37m%}(%{[00;35m%}%h%{[00;37m%}:%{[00;33m%}%l%{[00;37m%})"

# For scp:
# export PROMPT="%{[00;33m%}%n%{[00;37m%}@%{[00;33m%}%m%{[00;37m%}:%{[00;32m%}%~/%{[00m %} "
# export RPROMPT="%{[00;31m%}%?%{[00;37m%}:%{[00;35m%}%h%{[00;37m%}%{[00m%}(%{[00;36m%}%*%{[00;37m%})%{[00;33m%}%l%{[00m%}"
