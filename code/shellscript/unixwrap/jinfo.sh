#!/bin/sh
## Colours don't work!
# whitewin -geometry 80x50 -title "info $*" -e vim "+:Info $*"
whitewin -geometry 80x50 -title "info $*" -e info "$@"
