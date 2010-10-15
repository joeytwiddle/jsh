#!/bin/sh
## BUG TODO: If second arg is a non-existent directory, it moves the file to that name rather than creating a folder and moving the file into it!

TARGET=`lastarg "$@"`

## TARGET will be a file if src is just 1 file.
## If src is 1 directory, then TARGET will be a directory.
## Either way, SRC will be moved to TARGET, hence TARGET's parent dir will be needed.
if [ "$#" = 2 ] # && [ -f "$1" ]
then NEED_DIR=`dirname "$TARGET"`
## If src is multiple files/dirs/args, then TARGET should be an existing directory.
else NEED_DIR="$TARGET"
fi

mkdir -p "$NEED_DIR" &&

mv "$@"
