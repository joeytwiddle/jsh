if xisrunning; then
	bigwin "echo \"diff $@:\" && diff --side-by-side $@ | highlight \"\\\\\>\" red | more"
else
	echo "diff $@:"
	diff --side-by-side $@ |
	highlight \"\\\\\>\" red |
	more
fi
