# My dirhistory tool
# @sourceme You need to source this from your ~/.zshrc

if which d.zsh b.zsh f.zsh 2>&1 > /dev/null; then
	alias cd='d'
	#alias d='SUPPRESS_PRECMD=undo;SUPPRESS_PREEXEC=undo . $JPATH/tools/d.zsh'
	#alias d='SUPPRESS_PREEXEC=undo . $JPATH/tools/d.zsh'
	# In order to let d use cd's Tab-completion, we must make it a function
	d () {
		SUPPRESS_PREEXEC=undo . $JPATH/tools/d.zsh "$@"
	}
	compdef d=cd

	alias f='SUPPRESS_PREEXEC=undo . $JPATH/tools/f.zsh'
	alias b='SUPPRESS_PREEXEC=undo . $JPATH/tools/b.zsh'
else
	echo "Error with dirhistory: could not find d.zsh b.zsh f.zsh in path." >&2
fi
