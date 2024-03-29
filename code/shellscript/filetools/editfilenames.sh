#!/bin/bash
# Rename files using your favourite editor.

# See also: vidir

original_filenames="$(jgettmp original_filenames)"
new_filenames="$(jgettmp new_filenames)"
commands_to_run="$(jgettmp commands_to_run)"

if [ "$1" ]
then
	echolines "$@" > "$original_filenames"
else
	find . -maxdepth 1 |
	grep --binary-files=text -v '^\.$' |
	sort |
	sed 's+^\.\/++' > "$original_filenames"
fi

cp "$original_filenames" "$new_filenames"

#vi "$new_filenames"
#editandwait "$new_filenames"

# Find a suitable text editor
editor="$VISUAL"
[ -z "$editor" ] && editor="$EDITOR"
[ -z "$editor" ] && which editor >/dev/null 2>&1 && editor=editor
[ -z "$editor" ] && which nano   >/dev/null 2>&1 && editor=nano
[ -z "$editor" ] && which vi     >/dev/null 2>&1 && editor=vi
[ -z "$editor" ] && editor=no_editor_found

$editor "$new_filenames"

cat "$original_filenames" | sed "s+'+'\"'\"'+g" | sed "s+.*+'\0'+g" | dog "$original_filenames"
cat "$new_filenames"      | sed "s+'+'\"'\"'+g" | sed "s+.*+'\0'+g" | dog "$new_filenames"

paste -d " " "$original_filenames" "$new_filenames" |
sed "
	# SED_REMOVE
	# The first sed command removes any lines where the original and new files are an exact match
	# This is important to avoid the symlinks issue mentioned below
	# It's not 100% perfect, because it's still possible to create the same filename from two non-identical strings
	/^'\([^']*\)' '\1'$/d
	s/^/mv -iv /
" > "$commands_to_run"

echo "Will do the following:"
echo
cat "$commands_to_run"
echo

num_original="$(cat "$original_filenames" | wc -l)"
num_new="$(cat "$new_filenames" | wc -l)"
if [ ! "$num_original" = "$num_new" ]
then
	echo 'The number of filenames differ.  We cannot safely proceed!'
	exit 1
fi

# TODO: Check for this situation
#       This has partially mitigated by the SED_REMOVE above
echo "WARNING: If one of the files is a symlink to a folder, and you don't rename it, then mv will mv the symlink inside the folder!"
echo

echo -n "Proceed? [Yn] "

read decision
echo

# DONE (mostly): It would be good if we didn't try to rename files which were not changed.  Addressed by the SED_REMOVE above.
# BUG: If there is a destination file, `mv -i` will prompt for confirmation, but the greps will hide the prompt!
#      I have tried adding `--line-buffered`; perhaps that will help.  No, it didn't.

if [ "$decision" = y ] || [ "$decision" = Y ] || [ "$decision" = "" ]
then
	echo "Executing..."
	echo
	bash "$commands_to_run" 2>&1 |
	grep --line-buffered -v " are the same file$" |
	grep --line-buffered -v "cannot move .* to a subdirectory of itself" |
	grep --line-buffered . && echo
	echo "Done."
else
	echo "Doing nothing."
fi

jdeltmp "$original_filenames"
jdeltmp "$new_filenames"
jdeltmp "$commands_to_run"
