#!/bin/sh
## Er: this actually tries to do a patch...

## Trying to do it the wrong way
## Try again but use jdiffsimple...?

FILEA="$2"
FILEB="$1"
shift
shift

FILEAX=`jgettmp "worddiff: $FILEA.xescaped"`
FILEBX=`jgettmp "worddiff: $FILEB.xescaped"`
PATCH=`jgettmp "worddiff: patch"`
PATCHEDFILE=`jgettmp "worddiff: patchedfile"`

escapenewlines -x "$FILEA" > $FILEAX
escapenewlines -x "$FILEB" > $FILEBX

diff -C1 "$FILEAX" "$FILEBX" |
sed "s|^+ \(.*\)|+ `cursegreen;cursebold`\1`cursenorm`|" |
# sed "s|^! \(.*\)|! `curseyellow`\1`cursenorm`|" |
cat > "$PATCH" || exit 1

# cat "$PATCH" | head -50

cp "$FILEAX" "$PATCHEDFILE"
cat "$PATCH" |
patch "$PATCHEDFILE" || exit 1

# diff -C2 "$PATCHEDFILE" "$FILEAX" |
# sed "s|^+ \(.*\)|+ `cursered`\1`cursenorm`|" |
# cat > "$PATCH" || exit 1
# 
# cat "$PATCH" | head -50

# cp "$FILEAX" "$PATCHEDFILE"
# cat "$PATCH" |
# patch "$PATCHEDFILE"

cat "$PATCHEDFILE" |
unescapenewlines -x

jdeltmp $FILEAX $FILEBX $PATCH $PATCHEDFILE
