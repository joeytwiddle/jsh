cat "$@" |
sed '
s+\&+\&amp;+g
s+<+\&lt;+g
s+>+\&gt;+g
s+^$+<P>+
s+$+<BR>+
'
