# This is useful for systems which do not suppoer ls --color
# but do support ls -F, so we can search for filetypes!
# It is an approximation of my basic LSCOLS of directories, executables and symlinks.
# ls -atrF -C "$@" |
'ls' -atrF -C "$@" |
	if test -f "$HOME/.dircolors"; then
		SEDSTR=`fakelshi`
		sed "$SEDSTR"
	fi |
	# else # now always do this too:
		highlight "/" green |
		highlight -bold "*" red |
		highlight -bold "@" yellow
	# fi
