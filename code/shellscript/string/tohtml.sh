#!/bin/sh
if [ "$*" = "" ]
then cat
else echo -n "$1"
fi |
sed '
s+\&+\&amp;+g
s+<+\&lt;+g
s+>+\&gt;+g
s+^$+<P>+
s+$+<BR>+
s+<BR>$++
'
## TODO: The last replacement seems to compress empty lines.  I wanted that for something (don't remember what).  But I don't want it for makejshwebdocs!
## Ah it was energyradio that needed it.  And I think the reason was the last trailing <BR/> that bothered me.  Just converting a string using tohtml would create a newline.
## So we don't want the trailing newline?  ever?  or we don't want it if input was just 1 line?
