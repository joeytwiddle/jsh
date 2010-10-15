#!/bin/sh
for X in c shellscript haskell java; do

  echo
  echo "# code/$X -----------------------------------------------"
  cd $JPATH/code/$X
  cvsdiff

done
  
# cd $JPATH/code/java
# cvsdiff java

# cd $JPATH/code/c
# cvsdiff c

# cd $JPATH/code/shellscript
# cvsdiff shellscript

echo
echo "# servlets -----------------------------------------------"
cd $JPATH/code/java/servlets
cvsdiff

