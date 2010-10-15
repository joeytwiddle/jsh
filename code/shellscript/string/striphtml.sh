#!/bin/sh
if test ! "$1" = "-old" || ! jwhich lynx -quietly
then

	## TODO: Use lynx -stdin when "$*" = ""

	## Oops leaves a 0 length file
	TMPF=`jgettmp striphtml`
	cat "$@" > "$TMPF".html
	lynx -dump "$TMPF".html |
	tostring -x "References"
	jdeltmp "$TMPF" "$TMPF".html
	exit

else

shift

#################################################

# P_L not working!!
PRESERVE_LINKS=
if test "$1" = "-keeplinks"; then
	PRESERVE_LINKS="[^Aa]";
	shift
fi

NL="
"

cat "$@" |

## Trim leading whitespace
sed 's+^[	 ]*++' |

## Kill all artificial newlines
tr "\n" " " |

## Long regex matches (which often span lines in HTML):
# Too greedy!
# sed 's+<!--.*-->++g' |

## Retrieved specified newlines
sed "s+<\(BR\|br\|DT\|dt\)[^>]*>+\\$NL+g" |

## We did have problems before here
tee /tmp/debug1 |

if test "$PRESERVE_LINKS"
then
	sed 's+<\(A\|a\)[^>]*>+'`curseblue;cursebold`'+g' |
	sed 's+</\(A\|a\)[^>]*>+'`cursenorm`'+g'
else
	cat ## Appears to be needed
fi |

## ... and definitely after without the cat!
tee /tmp/debug2 |

sed "s+<\(H\|h\).[^>]*>+\\$NL+g" |
sed "s+</\(H\|h\).[^>]*>+\\$NL+g" |
tr -s "\n" |
sed "s+<\(p\|P\)[^>]*>+\\$NL\\$NL+g" |
sed "s+</\(BLOCKQUOTE\|blockquote\)[^>]*>+\\$NL\\$NL+g" |

## Finally remove all remaining tags except those preserved
sed "s+<$PRESERVE_LINKS[^>]*>++g" |

## Decode special HTML characters to ASCII
sed '
   s+&quot;+"+g
	s+&gt;+>+g
	s+&lt;+<+g
	s+&nbsp;+ +g
' |
sed 's+^[	 ]*++' |
sed "
	s+&#149;+ - +g
	s+&#146;+'+g
"

fi

