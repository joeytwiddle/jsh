#!/usr/bin/env bash
set -e

# If the file is a text file, this script will show you the contents
# But if it's not a text file, then it will try to work out what type of file it is, and show details about it, or what is inside it

# Adapted from https://unix.stackexchange.com/a/275691/33967
is_binary() {
    LC_MESSAGES=C grep -Hm1 '^' < "$1" 2>&1 | grep -q '\(^Binary\|: binary file matches$\)'
}

pager() {
    if which bat >/dev/null 2>&1
    then
        bat -f --style=plain "$1"
    else
        less -REX "$1"
    fi
}

if [ -z "$1" ] || [ "x$1" = "x-" ]
then
    # Presumably we are being piped input
    pager -
    exit "$?"
fi

for filename
do
    if is_archive "$filename"
    then
        #nicels -l "$filename"
        #echo
        #echo "Content:"
        list_files_in_archive "$filename"
    elif is_binary "$filename"
    then
        file "$filename"
    elif [ -d "$filename" ]
    then
        nicels -l "$filename/"
    elif [ -f "$filename" ]
    then
        # Show contents
        pager "$filename"
    else
        nicels -ld "$filename"
    fi
done
