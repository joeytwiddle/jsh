## This script should be sourced.  It will print the error message you provide, then exit the current shell with exit code 1.

error "$@"
exit 1
