#!/bin/sh

# Like `npm list` but only shows the top level of packages

npm list "$@" | grep "^[^\b][^\b][^\b][^\b]\b"

