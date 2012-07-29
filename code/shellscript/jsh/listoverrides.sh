#!/bin/sh

jshwarn "Note: jsh policy changed in 2008.  Now it adds itself to the end of your PATH, so it will not override existing executables."
jshinfo "Therefore jsh scripts with name conflicts are now labelled as 'masked' rather than 'overrides'!  They should probably all be renamed/namespaced to fix this, e.g. mplayer -> jmplayer or jshmplayer"
jshinfo "Then we will use an alias or function to redirect commands given in the user shell to our jsh version, but hopefully this will not happen when are running scripts from our shell."

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

ALL_NONJSH_COMMAND_NAMES=`jgettmp listoverrides`
ALL_JSH_SCRIPT_NAMES=`jgettmp listoverrides`

	echo "$PATH" |
	tr : '\n' |
	grep -v "$JPATH" |
	while read PATHDIR
	do
		'ls' $PATHDIR
	done > $ALL_NONJSH_COMMAND_NAMES

JSHS=`
	'ls' $JPATH/tools
	alias | sed 's+.* \(.*=\).*+\1+'
`

echo "$JSHS" > "$ALL_JSH_SCRIPT_NAMES"

intersection $ALL_NONJSH_COMMAND_NAMES $ALL_JSH_SCRIPT_NAMES |

while read NAME
do
	# echo `which "$NAME"`" overrides "`jwhich "$NAME"`
	echo "jsh's `cursecyan`$NAME`cursenorm` is masked by `curseyellow`"`jwhich "$NAME"``cursenorm`
done

jdeltmp $ALL_JSH_SCRIPT_NAMES

echo
echo "Generally, jsh only overrides an existing program when it improves the functionality of that program."
echo "All jsh scripts live in $JPATH/tools, unless they are imported as shell functions or aliases."
echo "You can see what these scripts do with: jdoc <script>"
echo "NB: listoverrides probably failed to obtain your shell's aliases and functions, so check them yourself (declare -f in zsh)!"
echo "Furthermore, I only checked $PATH, which only contain sbins's if you are currently root."
