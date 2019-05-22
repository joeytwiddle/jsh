#!/bin/sh
# Not to be confused with the npm prettydiff package
diff "$@" | diffhighlight | more
