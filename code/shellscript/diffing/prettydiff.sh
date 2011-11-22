#!/bin/sh
diff "$@" | diffhighlight | more
