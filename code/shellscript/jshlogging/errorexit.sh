# jsh-ext-depends: basename
# jsh-depends: error
## This script should be sourced.  It will print the error message you provide (if using bash but not always with sh), then exit the current shell with exit code 1.

error "[`basename "$0"`]" "$@"
exit 1
