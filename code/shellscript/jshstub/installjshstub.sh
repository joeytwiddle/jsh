## Quick installation with: wget -nv "http://hwi.ath.cx/installjshstub" -O - | sh
## Although for some reason (on ghostpuppy) this dropped me out of zsh :-( (even using zsh instead of sh above)

JPATH=/tmp/jsh-$$
JSH_STUB_NET_SOURCE="http://hwi.ath.cx/jshstubtools/"

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
## Needed for jsh to believe system is present!
ln -s tools/startj-hwi ./startj
## But we don't use it because jshstub needs $0 in tools directory.

echo
echo "### Stub jshenv installed in $JPATH"
echo

if which zsh 2>&1 > /dev/null
then
	echo "### To start jshenv in zsh, type the following:"
	echo "zsh"
	echo "export JPATH=$JPATH"
	echo "source \$JPATH/tools/startj-hwi"
	echo
fi

# echo "### Or for bash type:"
# echo "bash"
# echo "export JPATH=$JPATH"
# echo "alias source=\"'.' \$JPATH/tools/joeybashsource\""
# echo "alias .=\"'.' \$JPATH/tools/joeybashsource\""
# echo "source \$JPATH/tools/startj-hwi"
# echo

cat > $JPATH/jsh << !
bash --rcfile $JPATH/jshrc
!
chmod a+x $JPATH/jsh

cat > $JPATH/jshrc << !
export JPATH=$JPATH
export JSH_STUB_NET_SOURCE=$JSH_STUB_NET_SOURCE
alias source="'.' \$JPATH/tools/joeybashsource"
alias .="'.' \$JPATH/tools/joeybashsource"
source \$JPATH/tools/startj-hwi
!

echo "### To start jshenv in bash type:"
echo "$JPATH/jsh"
echo
