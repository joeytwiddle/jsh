#!/bin/sh
# Rename files using your favourite editor.

original_filenames="$(jgettmp original_filenames)"
new_filenames="$(jgettmp new_filenames)"
commands_to_run="$(jgettmp commands_to_run)"

if [ "$1" ]
then
	echolines "$@" > "$original_filenames"
else
	find . -maxdepth 1 |
	grep -v '^\.$' |
	sort |
	sed 's+^\.\/++' > "$original_filenames"
fi

cp "$original_filenames" "$new_filenames"

#vi "$new_filenames"
#editandwait "$new_filenames"

# Find a suitable text editor
editor="$VISUAL"
[ -z "$editor" ] && editor="$EDITOR"
[ -z "$editor" ] && which editor >/dev/null && editor=editor
[ -z "$editor" ] && which nano   >/dev/null && editor=nano
[ -z "$editor" ] && which vi     >/dev/null && editor=vi
[ -z "$editor" ] && editor=no_editor_found

$editor "$new_filenames"

cat "$original_filenames" | sed "s+'+'\"'\"'+g" | sed "s+.*+'\0'+g" | dog "$original_filenames"
cat "$new_filenames"      | sed "s+'+'\"'\"'+g" | sed "s+.*+'\0'+g" | dog "$new_filenames"

paste -d " " "$original_filenames" "$new_filenames" |
sed 's+^+mv -iv +' > "$commands_to_run"

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
echo "WARNING: If one of the files is a symlink to a folder, and you don't rename it, then mv will mv the symlink inside the folder!"
echo

echo -n "Proceed? [Yn] "

read decision
echo

# TODO: It would be good if we didn't try to rename files which were not changed.

if [ "$decision" = y ] || [ "$decision" = Y ] || [ "$decision" = "" ]
then
	echo "Executing..."
	echo
	bash "$commands_to_run" 2>&1 |
	grep -v " are the same file$" |
	grep -v "cannot move .* to a subdirectory of itself" |
	grep . && echo
	echo "Done."
else
	echo "Doing nothing."
fi

jdeltmp "$original_filenames"
jdeltmp "$new_filenames"
jdeltmp "$commands_to_run"
