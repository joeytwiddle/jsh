echo "mkdir -p \$HOME/0MailEvolution"

echo "## Purge old:"
if test -e "$HOME/0MailEvolution"
then
	find $HOME/0MailEvolution/ -maxdepth 1 -type l -name "\|*" |
	sed 's+^+rm "+;s+$+"+'
fi

if test -e "$HOME/0MailEvolutionTree"
then
echo
echo "del \"\$HOME/0MailEvolutionTree\""
echo
fi

echo "## Link new:"

find $HOME/evolution/local/ -name "mbox" |

while read X
do

	Y=`
		echo "$X" |
		tr " " "_" |
		sed "s+^$HOME/evolution/local++" |
		sed "s+/mbox$++" |
		sed "s+/subfolders/+|+g" |
		# sed "s+\(.*\)/\(.*\)$+\1|\2+" |
		sed 's+/+|+g' |
		sed "s+^ ++"
		# sed 's+^|+\\\\+'
	`
	echo "ln -s \"$X\" \"\$HOME/0MailEvolution/$Y\""
	# ln -s "$X" "./$Y"

	Z=`echo "$Y" | tr "|" "/" | sed "s+/$++"`
	Q=`echo "$X" | sed 's+/mbox$++'`
	if find "$Q/subfolders" -type f > /dev/null 2> /dev/null
	then
		echo "mkdir -p \"\$HOME/0MailEvolutionTree/$Z\""
		echo "ln -s \"$X\" \"\$HOME/0MailEvolutionTree/$Z/0mbox\""
	else
		echo "mkdir -p \""`dirname "\$HOME/0MailEvolutionTree/$Z.mbox"`"\""
		echo "ln -s \"$X\" \"\$HOME/0MailEvolutionTree/$Z.mbox\""
	fi

done
