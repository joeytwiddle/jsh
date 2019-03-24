# jsh-ext-depends: basename
# jsh-depends: error
#
# @deprecated  Use `error "<message>"` followed by `exit <non-zero-code>` instead.
#
# Why expand this common pattern inline?
#
# - Using `exit` makes it clear what the outcome will be, both to developers and to static analysis.
# - It avoids the issues outlined below.
#
# This script should be sourced.  It will print the error message you provide (if using bash but not always with sh), then exit the current shell with exit code 1.
#
# It should only be used from scripts running in bash!  That will produce:
#
#     ERROR: [<scriptname>] <error_arguments>...
#
# If the current shell is 'sh' then we get:
#
#     ERROR: [<scriptname>] <original_arguments>...
#
# If the current shell is 'zsh' then we get:
#
#     ERROR: [errorexit] <error_arguments>...

error "[`basename "$0"`]" "$@"
exit 1
