## Originally for svn diffs.
## Added regexps for cvs diffs.
highlight -bold "^\(+++\|---\|===\|Index\|@\|\*\*\*\|[0-9][0-9acd,]*$\).*" magenta |
highlight       "^[+>].*" green |
highlight -bold "^[-<].*" red |
highlight       "^[|\!].*" yellow
