#!/bin/sh

# Like `npm list` but only shows the top level of packages

npm list --depth=0 "$@"

#| grep "^[^\b][^\b][^\b][^\b]\b"

