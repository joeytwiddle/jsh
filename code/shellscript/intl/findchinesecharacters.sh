#!/bin/sh
TMPFILE=`jgettmp`
cat > "$TMPFILE"

(

# cat "$TMPFILE" |
# # Split double-chars into double and two singles
# sed 's+\([^ -~][^ -~]\)\([^ -~][^ -~]\)+\
# \1\2\
# +g'

cat "$TMPFILE" |
sed 's+\([^ -~].\)+\
\1\
+g'

# cat "$TMPFILE" |
# sed 's+\([^ -~][ -~]\)+s\
# w \1\
# +g'

# cat "$TMPFILE" |
# sed 's+\([ -~][^ -~]\)+s\
# W \1\
# +g'

) |

# Clear empty lines
sed 's/[ -~]*//g' |
trimempty
# sed 's/[ -~]*\(..\)/\1\
# /g' | sed 's/[ -~]*$//' | trimempty
# sed 's/[^ -~]./<ch val="\0">/g'
