# My dirhistory tool
# You need to source this in your ~/.<mysh>rc

if which d.zsh b.zsh f.zsh 2>&1 > /dev/null; then
	alias cd='d'
	# alias d='SUPPRESS_PRECMD=undo;SUPPRESS_PREEXEC=undo . $JPATH/tools/d.zsh'
	alias d='SUPPRESS_PREEXEC=undo . $JPATH/tools/d.zsh'
	alias f='SUPPRESS_PREEXEC=undo . $JPATH/tools/f.zsh'
	alias b='SUPPRESS_PREEXEC=undo . $JPATH/tools/b.zsh'
else
	echo "Error with dirhistory: could not find d.zsh b.zsh f.zsh in path." >&2
fi
