echo "Undoing last commit and index, leaving files alone"
git reset 'HEAD~~1'
echo "The \"lost\" commit will remain for a while in git reflog"
