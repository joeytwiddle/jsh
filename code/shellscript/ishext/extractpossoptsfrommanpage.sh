# jsh-depends: extractregex
# jsh-ext-depends: col

'man' "$@" 2> /dev/null |
col -bx | ## strip those dirty control-chars
extractregex -atom "[ 	]((-|--)[A-Za-z0-9-=]+)" ## accepts '=', and accepts alphanums after the '=' too (often the units or the type of the value)
