#!/bin/sh
# jsh-ext-depends: vsound
# jsh-depends: rotate

FILE=/tmp/ripped_audio.wav

if [ ! "$1" ] || [ "$1" = --help ]
then
echo
echo "ripaudio <command>..."
echo
echo "  will execute the command, and save audio output to $FILE"
echo
exit 1
fi

if [ -f "$FILE" ]
then rotate "$FILE"
fi

vsound -v -d -t -f "$FILE" "$@"
