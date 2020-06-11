#!/bin/sh
# jsh-depends: highlight
# jsh-depends-ignore: reverse

if which less >/dev/null 2>&1
then more="less -R -X -E"
else more="more"
fi

if [ "$1" = -nm ]
then more="cat" ; shift
fi
#if [ ! -t 1 ]
#then more="cat"
#fi

cat "$@" |
## Ideally we would do this to all but the first one
sed 's+^Index: +\n\n\n\0+' |
## Originally for svn diffs.
## Added regexps for cvs diffs.
highlight -bold -reverse "^\(commit \).*" yellow |
highlight -bold "^\(Author: \|Date: \).*" yellow |
highlight -bold "^\(+++ \|--- \|=== \|diff \|[^-+<> 	@,|\!=0-9]\).*" cyan |
highlight -bold "^\(@\|\*\*\*\|[0-9][0-9acd,]*$\).*" magenta |
highlight -bold "^[+>].*" green |
highlight -bold "^[-<].*" red |
highlight -bold "^[|\!].*" yellow |
## For user convenience, we almost always want to pipe to more
## If you ever don't want to, pass -nm!
$more
