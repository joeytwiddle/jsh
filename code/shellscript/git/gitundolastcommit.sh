echo "Undoing last commit and index, leaving files alone"
#git reset 'HEAD~~1'
git reset 'HEAD~'
echo "The \"lost\" commit will remain for a while in git reflog"
