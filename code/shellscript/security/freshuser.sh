#!/bin/bash

# Simple convenience tool.  Type freshuser when you want to try something
# without being your normal user.

cmd="`escapeargs "$@"`"
[ -z "$cmd" ] && cmd="/bin/bash"

## -x might use my zsh PS1 if we dont shebang /bin/bash at the top
# . hwipromptforbash
# export PS1
# set -x

sudo useradd -m freshuser

echo "Entering temporary account"
# # TODO: export X session!  or start X session!
# if [ -z "$*" ]
# then
	# sudo su - freshuser -c /bin/bash
# else
	# sudo su - freshuser -c "$*"
# fi

sudo su - freshuser -c "$cmd"

sudo userdel freshuser
sudo rm -rf /home/freshuser
# sudo $JPATH/jsh del /home/freshuser

