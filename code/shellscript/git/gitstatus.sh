gitignoreExpr="none_of_your_files_look_like_this.noodles"
if [ -f .gitignore ]
then gitignoreExpr="\($( cat .gitignore | globtoregexp | sed 's+$+\\|+' | tr -d '\n' | sed 's+\\|$++' )\)$"
fi
git status "$@" |
highlight -bold "^#	*added:.*" green |
highlight "^#	modified:.*" green |
highlight -bold "^#	deleted:.*" red |
highlight -bold "^#	new file:.*" yellow |
grep -v "^#	$gitignoreExpr" |
highlight "^#	.*" yellow |
## Alternatively, diffs may be colored by setting [color "status"] section of .gitconfig
# ( least || most || more )
more
