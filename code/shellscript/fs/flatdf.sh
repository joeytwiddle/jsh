# jsh-ext-depends: sed
# jsh-depends: escapenewlines unescapenewlines

## Reformats df output to deal with long lines which can throw it off
## Maybe we should be using mtab instead.

## I have started using flatdf instead of df, because any Linux running
## devfs gets given huge device names for IDE disks, making the reformatting
## vital (for line-based scripts anyway).

## TODO: CONSIDER: Couldn't we just use env COLUMNS=65535 df ... ?

df "$@" |
sed 's+^\([^ ]*\)[ ]*$+\1 JOIN_LINE+' |
escapenewlines |
# pipeboth |
sed 's+ JOIN_LINE\\n+ +g' |
unescapenewlines |
columnise

