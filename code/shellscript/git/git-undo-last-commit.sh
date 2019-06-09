#!/usr/bin/sh
echo "Undoing last commit and index, leaving files alone"
git reset 'HEAD~'
echo "The \"lost\" commit will remain for a while in git reflog"
