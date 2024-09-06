#!/usr/bin/env bash
set -e

# If the file is a text file, this script will show you the contents
# But if it's not a text file, then it will try to work out what type of file it is, and show details about it, or what is inside it

if [ -n "$2" ]
then
    for filename in "$@"
    do
        printf "%s\n" "=============================================================================="
        printf "%s\n" "$filename"
        printf "%s\n" "=============================================================================="
        show_file_contents "$filename"
        echo
    done | less -REX
    exit
fi

filename="$1"

# Adapted from https://unix.stackexchange.com/a/275691/33967
is_binary() {
    LC_MESSAGES=C grep -Hm1 '^' < "$1" 2>&1 | grep -q '\(^Binary\|: binary file matches$\)'
}

is_image() {
    file --mime-type "$1" | grep 'image/[^ ]*$' >/dev/null
}

pager() {
    #export COLUMNS=20
    #export COLUMNS="$(tput cols)"
    if which bat >/dev/null 2>&1
    then
        bat --theme="Monokai Extended Bright" --pager="less -REX" -f --style=plain "$1"
    else
        less -REX "$1"
    fi
}

if [ -z "$filename" ]
then
    # Presumably we are being piped input
    pager -
elif [ ! -e "$filename" ] && [ ! -L "$filename" ]
then
    echo "No such file or directory: ${filename}" >&2
    exit 1
elif is_archive "$filename"
then
    #nicels -l "$filename"
    #echo
    #echo "Content:"
    list_files_in_archive "$filename"
# Experiment disabled because sometimes when running in fzf, kitty's output will mess up the terminal
#elif is_image "$filename" && which kitty >/dev/null 2>&1
#then
#    # Unfortunately, this does not work inside fzf preview window
#    kitty +kitten icat "$filename"
#    # This tries (to render as boxes of colour) but fails
#    #img2txt "$filename"
elif is_binary "$filename"
then
    if which bingrep >/dev/null 2>&1
    then bingrep "$filename" | less -REX
    elif which hexdump >/dev/null 2>&1
    then hexdump -C "$filename" | less -REX
    else file "$filename"
    fi
elif [ -d "$filename" ]
then
    (
        echo "Contents of $(cursegreen)$(realpath "$filename")$(cursenorm)"
        nicels -l "$filename/"
    ) | less -REX
elif [ -f "$filename" ]
then
    # Show contents
    pager "$filename"
else
    nicels -ld "$filename"
fi
