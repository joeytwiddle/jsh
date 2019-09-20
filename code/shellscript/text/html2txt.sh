#!/usr/bin/env bash

if false # command -v lynx >/dev/null 2>&1
then
    url="$*"
    [ -z "$url" ] && url="-stdin"
    lynx -dump -nolist "$url"
else
    # Strips tags but does not strip CSS and does not unescape text content
    cat "$@" | sed -e 's/<[^>]*>//g' | sed 's+^\s*$++'
fi
