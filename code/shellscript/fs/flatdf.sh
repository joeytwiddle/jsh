# jsh-ext-depends: sed
# jsh-depends: escapenewlines unescapenewlines
## Reformats df output to deal with long lines which can throw it off
## Maybe we should be using mtab instead.

df "$@" |
sed 's+^\([^ ]*\)[ ]*$+\1 JOIN_LINE+' |
escapenewlines |
# pipeboth |
sed 's+ JOIN_LINE\\n+ +g' |
unescapenewlines

