# My dirhistory tool
# You need to source this in your ~/.<mysh>rc

if which d.zsh b.zsh f.zsh 2>&1 > /dev/null; then
	alias cd='. $JPATH/tools/d.zsh'
	alias d='. $JPATH/tools/d.zsh'
	alias f='. $JPATH/tools/f.zsh'
	alias b='. $JPATH/tools/b.zsh'
else
	echo "Error with dirhistory: could not find d.zsh b.zsh f.zsh in path." >&2
fi
