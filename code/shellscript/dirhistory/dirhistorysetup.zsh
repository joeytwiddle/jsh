# My dirhistory tool
# @sourceme You need to source this from your ~/.zshrc or ~/.bashrc

# Despite the name, this supports both bash and zsh shells.
# TODO: rename me!

if which d.zsh b.zsh f.zsh >/dev/null 2>&1
then
	alias cd='d'
	#alias d='SUPPRESS_PRECMD=undo;SUPPRESS_PREEXEC=undo . $JPATH/tools/d.zsh'
	#alias d='SUPPRESS_PREEXEC=undo . $JPATH/tools/d.zsh'

	# In zsh, completion of filenames containing spaces would not continue after a space
	# In order to let d use cd's Tab-completion in zsh, we must make it a function, and use compdef
	# (For bash either the alias or the function is fine.)
	d() {
		SUPPRESS_PREEXEC=undo . "$JPATH/tools/d.zsh" "$@"
	}
	if [ -n "$ZSH_NAME" ]
	then compdef d=cd
	fi

	alias f='SUPPRESS_PREEXEC=undo . "$JPATH/tools/f.zsh"'
	alias b='SUPPRESS_PREEXEC=undo . "$JPATH/tools/b.zsh"'

	alias dh='dirhistory'
else
	echo "Error with dirhistory: could not find d.zsh b.zsh f.zsh in path." >&2
fi
