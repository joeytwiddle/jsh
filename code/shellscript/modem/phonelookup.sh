if [ "$1" = -check ]
then CHECK=true; shift
else CHECK=
fi
NAME="$1"
BOOK="$HOME/j/org/real-phonebook.txt"

for REGEXP in "^$NAME: [0-9]+" "^$NAME.*:.*" "$NAME.*"
do

	LINE=`cat "$BOOK" | extractregex "$REGEXP"`
	[ "$LINE" ] && break

done # | extractregex "$REGEXP"

NUMBER=`echo "$LINE" | extractregex "[[:digit:]]+"`

if [ $CHECK ]
then

	echo "`curseyellow`From text in phonebook:`cursenorm`"    >&2
	echo "$LINE"                                              >&2
	echo "`curseyellow`I guessed number:`cursenorm`"          >&2
	echo "$NUMBER"                                            >&2
	echo -n "`curseyellow`Is this correct? [Y/n] `cursenorm`" >&2

	read DECISION

	if [ "$DECISION" = Y ] || [ "$DECISION" = y ] || [ "$DECISION" = "" ]
	then echo "$NUMBER"
	fi

else

	echo "$LINE"
	# echo "$NUMBER"

fi
