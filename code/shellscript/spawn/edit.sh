# jsh-depends: editandwait xisrunning
if xisrunning; then
	editandwait "$@" &
else
	editandwait "$@"
fi
