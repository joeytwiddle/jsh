# unj decodeslashn "$@"

## In fact, for decoding a newline-escaped stream, tr -d '\n' should never be harmful, so the -x option needn't really be specified, it could be assumed.

CONTRACT_WORDS=
if test "$1" = -x
then shift; CONTRACT_WORDS=true
fi

cat "$@" |

if test "$CONTRACT_WORDS"
then tr -d '\n'
else cat
fi |

unj decodeslashn

exit

# Not entirely working because not parsed concurrently:
# Would be OK to match (\\n|\\\\) if we could do different things when we replace
# TRY: \(\\\(n\)\|\\\(\\\)\) -> \2\3
# oh but we want \n instead of \2 :-(
# sed 's+\\n+\
# +g;s+\\\\+\\+g'

# Inelegant fudge:
UNIQUE="jadljfofjw90f02""4329r2934SFKSLFSL"
sed 's+\\\\+$UNIQUE+g;s+\\n+\
+g;s+$UNIQUE+\\+g'
