# It runs with whatever shell you are using

#!/bin/sh
#!/bin/ash
#!/bin/csh
#!/bin/tcsh
#!/bin/zsh
#!/bin/bash

#  pass remaining arg. vector in 3 ways:

# you might uncomment lines which start with "# echo"

# echo '  Using $*'
# quasi $1 $2 ...
# echoargs $*

# echo '  Using "$*"'
# quasi "$1 $2 ...", i.e. all args combined in a single
# word
# echoargs "$*"

echo -n '  "$@"      '
# quasi "$1" "$2" ..., i.e. preserve word boundaries but may
# cause troubles
echoargs "$@"

echo -n '  ${1+"$@"} '
# quasi "$1" "$2" ..., i.e. preserve word boundaries
#  If parameter 1 is set (i.e. arg. vector contains at least
#  one word) substitute "$@" else substitute nothing.
echoargs ${1+"$@"}
