# My dirhistory tool
# You need to source this in your ~/.<mysh>rc

# For zsh:
runnable () {
	which "$1" > /dev/null 2>&1
}

if runnable d.zsh && runnable b.zsh && runnable f.zsh; then
	alias cd='. $JPATH/tools/d.zsh'
	alias d='. $JPATH/tools/d.zsh'
	alias f='. $JPATH/tools/f.zsh'
	alias b='. $JPATH/tools/b.zsh'
else
	echo "Error with dirhistory: could not find d.zsh b.zsh f.zsh in path." > /dev/stderr
fi
