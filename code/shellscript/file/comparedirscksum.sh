cksumall "$1" > $JPATH/tmp/1.cksum
cksumall "$2" > $JPATH/tmp/2.cksum

# diff $JPATH/tmp/1.cksum $JPATH/tmp/2.cksum

echo "Files that are different:"
jfc $JPATH/tmp/1.cksum $JPATH/tmp/2.cksum | sed "s+.*\.\/++"
echo
# echo "Files that are the same:"
# jfc common $JPATH/tmp/1.cksum $JPATH/tmp/2.cksum | sed "s+.*\.\/++"
