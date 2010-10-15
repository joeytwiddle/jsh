#!/bin/sh
X="$@"
cp "$X" "$X.b4rt"
cat "$X.b4rt" | sed "s+	+  +g" > "$X"
# cat "$X.b4rt" | tr "\t" " " > "$X"
