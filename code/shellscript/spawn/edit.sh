# jsh-depends: editandwait xisrunning
## Safe as fuck!  Pops it up in a new screen window:
if [ "$STY" ]
then
	screen -X screen editandwait "$@"

elif xisrunning
then
	editandwait "$@" &

else
	editandwait "$@"

fi
