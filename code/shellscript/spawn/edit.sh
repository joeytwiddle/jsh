# jsh-depends: editandwait xisrunning

## Safe as fuck!  Pops it up in a new screen window:
## OK, except a lot of the time I'd rather prioritise X (which doesn't get checked until editandwait!)
## TODO: also, screen -X loses our shell env including PWD, which is bad for local filenames and external executions from the editor.  Set the WD!
if [ "$STY" ]
then
	screen -X screen editandwait "$@"

elif xisrunning
then
	editandwait "$@" &

else
	editandwait "$@"

fi
