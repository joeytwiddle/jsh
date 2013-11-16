#!/bin/sh
# jsh-depends: highlight
# jsh-depends-ignore: reverse

more="more"
if [ "$1" = -nm ]
then more="cat" ; shift
fi

cat "$@" |
## Ideally we would do this to all but the first one
sed 's+^Index: +\n\n\n\0+' |
## Originally for svn diffs.
## Added regexps for cvs diffs.
highlight -bold "^\(+++\|---\|===\|[Ii]ndex\).*" cyan |
highlight -bold -reverse "^[^-+<> 	@,|\!=0-9].*" cyan |
highlight -bold "^\(@\|\*\*\*\|[0-9][0-9acd,]*$\).*" magenta |
highlight       "^[+>].*" green |
highlight -bold "^[-<].*" red |
highlight       "^[|\!].*" yellow |
## For user convenience, we almost always want to pipe to more
## If you ever don't want to, pass -nm!
"$more"
