#!/usr/bin/env bash

(

	if command -v cht.sh >/dev/null 2>&1
	then verbosely cht.sh "$@" ; echo
	else
		# Use the cht.sh website
		#curl cht.sh/"$*"

		# # If you use cht.sh, then you don't need to run cheat or tldr, because cht.sh will query them for us
		# However, they are good alternatives if you have no internet connection
		# And cheat (go) is the fastest I have used

		if command -v cheat >/dev/null 2>&1
		then verbosely cheat "$@" ; echo
		fi

		if command -v tldr >/dev/null 2>&1
		then verbosely tldr "$@" ; echo
		fi
	fi

	if command -v bro >/dev/null 2>&1 && [ -x "$(command -v bro)" ]
	then verbosely bro "$@" ; echo
	fi

	own_cheatsheet="$HOME/Dropbox/cheatsheets/$1.md"
	if [ -f "$own_cheatsheet" ]
	then verbosely cat "$own_cheatsheet" ; echo
	fi

	if command -v man >/dev/null 2>&1
	then verbosely man -a "$1" ; echo
	fi

) 2>&1 |

less -RX
