# jsh-depends: editandwait xisrunning
## Safe as fuck!  Pops it up in a new screen window:
## TODO: requires absolute path or doesn't work!
if [ "$STY" ]
then
	screen -X screen editandwait "$@"

elif xisrunning
then
	editandwait "$@" &

else
	editandwait "$@"

fi
