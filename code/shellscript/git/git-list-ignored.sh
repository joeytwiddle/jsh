# This one didn't work for me.  (Listed nothing!)
#git ls-files --ignored --exclude-standard

# This lists ignored directories but not the files below them
#git status --ignored

# This applies to `git list-files` and to `git clean`
echo "Note: Only files/folders under the current folder are listed.  cd to the top folder if you want to see all files."
echo

# This is the only one that lists the files below ignored directories
# But it also lists untracked files (which are not ignored)
# So it would be better named git-list-untracked-files-including-ignored-files
git ls-files --other

# This seems helpful too.  -n is dry run :)
#git clean -dXn
