## WIP!  jshhop is intended to be a replacement for ssh
## At the beginning of the session, it will do useful things
## such as update config between two machines.
## NB: currently runs without jsh env deps but that will change!
## It needs to know where the other version is.

## Since different versions of this script are likely to have a different protocol,
## it might make sense if one of the peers is completely submissive to the other,
## eg. the local machine might send the remote machine scripts or commands to execute.

## Ideally we would make it transparent: non-echoing and non-interactive even
## in the fact of failed update patches to configs.

if [ "$1" = -server ]
then

	shift

	# ...

	read HELLO
	echo "hi local, got ur msg: $HELLO"

	echo "jshhop done"
	## Mm seems we've lost our env, maybe we should get bits of it sent to us!
	export TERM=vt100
	export COLUMNS=80
	zsh -i
	echo "jshhop: session ended"
	# j/jsh

else

	(
		echo "hello remote"
		cat
	) |

	# ssh "$1" j/tools/jshhop -server

	ssh "$1" j/tools/jshhop -server |

	(

		while read RESPONSE
		do
			echo "jshhop local received: $RESPONSE"
			[ "$RESPONSE" = "jshhop done" ] && break
		done

		cat

	)

fi
