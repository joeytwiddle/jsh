## Quick installation with: wget -nv "http://hwi.ath.cx/installjshstub" -O - | sh
## Although for some reason (on ghostpuppy) this dropped me out of zsh :-( (even using zsh instead of sh above)

export JPATH=/tmp/jsh-$$
export JSH_STUB_NET_SOURCE="http://hwi.ath.cx/jshstubtools/"

if which wget 2>&1 > /dev/null
then WGETCOM="wget -nv -O -"
else WGETCOM="lynx --source"
fi

mkdir -p $JPATH
cd $JPATH

mkdir tools tmp
cd tools
$WGETCOM "$JSH_STUB_NET_SOURCE/jshstub" > jshstub
chmod a+x jshstub

## For bash experiment:
$WGETCOM "$JSH_STUB_NET_SOURCE/joeybashsource" > joeybashsource
chmod a+x joeybashsource

## Link all the jshtools to jshstub
# 'ls' /home/joey/j/tools/ |
# $WGETCOM "http://hwi.ath.cx/jshstubtools" -O - |
# grep "<img" | grep -v "Parent Directory" |
# sed 's+.*href="\(.*\)">.*+\1+' |
$WGETCOM "$JSH_STUB_NET_SOURCE/.listing" |
while read X
do ln -s jshstub "$X"
done 2>&1 |
grep -v "\(jshstub\|joeybashsource\).*File exists"

cd ..

# ln -s tools/jsh .
ln -s tools/startj-hwi ./startj ## Needed at least for jsh to start!

echo
echo "### Stub jsh installed in $JPATH"
echo

echo "### If you have zsh, type the following:"
echo "zsh"
echo "export JPATH=$JPATH"
echo "source \$JPATH/tools/startj-hwi"
echo
# echo "export JSH_STUB_NET_SOURCE=$JSH_STUB_NET_SOURCE"

echo "### Or to help debug (broken) bash support type:"
echo "bash"
echo "export JPATH=$JPATH"
echo "alias source=\"'.' \$JPATH/tools/joeybashsource\""
echo "alias .=\"'.' \$JPATH/tools/joeybashsource\""
echo "source \$JPATH/tools/startj-hwi"
echo

