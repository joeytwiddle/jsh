if xisrunning; then
	editandwait "$@" &
else
	editandwait "$@"
fi
