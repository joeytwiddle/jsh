#!/bin/sh
# NEEDED:
# If directory is specified without trailing /
#   JPATH is set without trailing / which is undesirable
# do dircolors
# install in bashrc (and bash_profile?)
# in makeport: doesn't refresh tools!
# link in tools directory
# talk about settings (editor...)
# set up sync client (and proper files)

echo "--- j installer ----------------"

echo "installj <os> [ <from dir> [ <to dir> ] ]"
echo "  where <os> = linux | unix | dos"

WHICHOS="$1"
FROM="$2"
JTO="$3"

if [ "$FROM" = "" ]; then
  FROM="$PWD/"
  echo "guessing <from dir> = \"$FROM\""
fi

if [ "$FROM" = "." ]; then
  FROM="$PWD/"
  echo "<from dir> = \"$FROM\""
fi

if [ "$JTO" = "" ]; then
  JTO="$HOME/j"
  echo "default <to dir> = \"$JTO\""
fi

if [ "$WHICHOS" = "" ]; then
  echo "Please specify OS"
  exit 1
fi

echo
echo "Starting install from \"$FROM\" to \"$JTO\""

if [ ! -f "$FROM/tools.tgz" ]; then
  echo "Error: \"tools.tgz\" not found in \"$FROM\""
  exit 1
fi

cd $HOME

if [ -d "$JTO" ]; then
  echo "Moving your previous $JTO to $JTO.old"
  mv "$JTO" "$JTO.old"
fi

if [ -d "$JTO" ]; then
  echo "Problem removing old \"$JTO\" directory.  Aborting install."
  exit 1
fi



# Create j directory
mkdir "$JTO"
cd "$JTO"

# Copy installation files into tmp dir
mkdir tmp
cd tmp
cp $FROM/* .
FROM="$PWD/"

cd "$JTO"
echo "Installing tools"
mkdir tools
cd tools
gunzip $FROM/tools.tgz
tar xf $FROM/tools.tar
cd ..



mkdir bin
mkdir out
mkdir trash
mkdir logs
mkdir data



if [ -f "$FROM/hwiport.tgz" ]; then
  echo "Installing code"
  mkdir code
  cd code
  gunzip $FROM/hwiport.tgz
  tar xf $FROM/hwiport.tar
  cd ..
else
  echo "\"hwiport.tgz\" not found in \"$FROM\".  Not installing code."
fi

ln -s code/c/joeylib .



# echo "export JPATH=$JTO" > $JTO/startj
# # old
# # echo "export JWHICHOS=$WHICHOS" >> $JTO/startj
# echo "export PATH=\$JPATH/tools:\$PATH" >> $JTO/startj
# echo "export CLASSPATH=\$JPATH/code/java:\$CLASSPATH" >> $JTO/startj
# echo "# . \$JPATH/tools/jshellalias" >> $JTO/startj
# echo "# . \$JPATH/tools/jshellsetup" >> $JTO/startj
# echo 'if [ ! "$@" = "" ]; then $@; fi' >> $JTO/startj
# chmod a+x $JTO/startj
ln -s "$JPATH/code/shellscript/init/startj-hwi.sh" "$JTO/startj"

echo "#define $WHICHOS" > $JTO/code/c/joeylib/whichos.c

. $JTO/startj

. $JTO/tools/alluptodate

echo
echo "Installation complete"
echo "$JTO : "
ls "$JTO"
echo
echo "Run $JTO/startj to start using j (eg. in" $HOME/.*shrc ")."
echo "Uncomment extra calls in $JTO/startj if you're feeling lucky!"
echo "For more command-line tools, run makebintools."
echo "For PhD work, run makephdbins.  jnn needs a trained net and snns."
