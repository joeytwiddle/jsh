export JPATH=/tmp/jsh-$$

mkdir -p $JPATH
cd $JPATH

mkdir tools
cd tools
wget "http://hwi.ath.cx/jshstubtools/jshstub" -O jshstub
chmod a+x jshstub
'ls' /home/joey/j/tools/ | while read X; do ln -s jshstub "$X"; done
cd ..

# ln -s tools/jsh .
# ln -s tools/startj-hwi ./startj

echo "Recommend:"
# echo "zsh"
# echo "export JPATH=$JPATH"
echo "source \$JPATH/tools/startj-hwi"

zsh
