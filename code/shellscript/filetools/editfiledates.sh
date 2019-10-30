#!/bin/sh
# Tweak file dates using your favourite editor.

commands_to_run="$(jgettmp commands_to_run)"

if [ -z "$1" ]
then
  editfiledates *
  exit
fi

(
  echo "# *** NOTE *** Be sure to edit the dates on the left, and not the filenames on the right!"
  echo
  echolines "$@" | sortfilesbydate |
  while read file
  do echo "touch -d \"$(date -r "$file")\" \"${file}\""
  done
) > "$commands_to_run"

#vi "$new_filenames"
#editandwait "$new_filenames"

# Find a suitable text editor
editor="$VISUAL"
[ -z "$editor" ] && editor="$EDITOR"
[ -z "$editor" ] && which editor >/dev/null 2>&1 && editor=editor
[ -z "$editor" ] && which nano   >/dev/null 2>&1 && editor=nano
[ -z "$editor" ] && which vi     >/dev/null 2>&1 && editor=vi
[ -z "$editor" ] && editor=no_editor_found

$editor "$commands_to_run"

echo "Will do the following:"
echo
cat "$commands_to_run"
echo

echo -n "Proceed? [Yn] "

read decision
echo

if [ "$decision" = y ] || [ "$decision" = Y ] || [ "$decision" = "" ]
then
        echo "Executing..."
        echo
        bash "$commands_to_run"
        echo "Done."
else
        echo "Doing nothing."
fi

jdeltmp "$commands_to_run"
