intersection () {
	FILE="$1"; shift
	cat "$@" |
	while read LINE
	do
		grep "^$LINE$" "$FILE"
		ERR="$?"
		[ "$ERR" = 1 ] || [ "$ERR" = 0 ] ||
		error "problem with regexp '$LINE' ?"
	done
}

TMPA=`jgettmp listoverrides`
TMPB=`jgettmp listoverrides`

	echo "$PATH" |
	tr : '\n' |
	grep -v "$JPATH" |
	while read PATHDIR
	do
		'ls' $PATHDIR
	done > $TMPA

JSHS=`
	'ls' $JPATH/tools
	alias | sed 's+.* \(.*=\).*+\1+'
`

echo "$JSHS" > "$TMPB"

intersection $TMPA $TMPB |

while read NAME
do
	# echo `which "$NAME"`" overrides "`jwhich "$NAME"`
	echo "jsh's `cursecyan`$NAME`cursenorm` overrides `curseyellow`"`jwhich "$NAME"``cursenorm`
done

jdeltmp $TMPB

echo
echo "Generally, jsh only overrides an existing program when it improves the functionality of that program."
echo "All jsh scripts live in $JPATH/tools, unless they are imported as shell functions or aliases."
echo "You can see what these scripts do with: jdoc <script>"
echo "NB: listoverrides probably failed to obtain your shell's aliases and functions, so check them yourself!"
echo "Furthermore, I only checked $PATH, which only contain sbins's if you are currently root."
