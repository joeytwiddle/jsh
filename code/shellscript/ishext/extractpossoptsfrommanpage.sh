# jsh-ext-depends: col
# jsh-depends: extractregex

# unj man "$@" 2> /dev/null |
# /usr/bin/man "$@" 2> /dev/null |
'man' "$@" 2> /dev/null |
col -bx | ## strip those dirty control-chars
# extractregex "(-|--)[A-Za-z0-9-]+" | ## nice and simple
# extractregex -atom "[ 	]((-|--)[A-Za-z0-9-]+)" | ## avoids the "-de-blah" in "blah-de-blah"
# extractregex -atom "[ 	]((-|--)[A-Za-z0-9-]+(=|))" | ## accepts ending =, but does not accept explanations
extractregex -atom "[ 	]((-|--)[A-Za-z0-9-=]+)" # | ## accepts '=', and accepts alphanums after the '=' too (often the units or the type of the value)
# removeduplicatelines
