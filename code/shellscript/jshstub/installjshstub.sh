export JPATH=/tmp/jsh-$$

mkdir -p $JPATH
cd $JPATH

mkdir tools
cd tools
wget "http://hwi.ath.cx/jshstubtools/jshstub" -O jshstub
chmod a+x jshstub

## Link all the jshtools to jshstub
'ls' /home/joey/j/tools/ |
while read X
do ln -s jshstub "$X"
done 2>&1 |
grep -v "jshstub.*File exists"

cd ..

# ln -s tools/jsh .
ln -s tools/startj-hwi ./startj ## Needed at least for jsh to start!

echo "@ Stub jsh installed in $JPATH"

echo "@ I have already done:"
echo "export JPATH=$JPATH"

echo "@ Type the following to start:"
echo "source \$JPATH/tools/startj-hwi"
zsh || echo "Sorry jshstub only works with zsh (not bash)."

# $JPATH/tools/joeybashsource /
# echo "@ Type the following to start:"
# echo "alias source='. $JPATH/tools/joeybashsource'"
# echo "source \$JPATH/tools/startj-hwi"
# bash
