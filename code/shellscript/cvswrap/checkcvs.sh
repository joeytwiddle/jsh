#!/bin/sh
REPOS="$1"

if test "$REPOS" = ""; then
  echo "Provide <repository>"
  echo "Checks out a temporary version and checks similarities / differences with your current version."
  exit 1
fi

SRC=`absolutepath "$REPOS"`

echo "Comparing your $SRC against a fresh cvs checkout of $REPOS"

'rm' -rf "/tmp/ckout"
mkdir -p /tmp/ckout
'cd' /tmp/ckout
cvs checkout "$REPOS" > /dev/null 2>&1

comparedirscksum "$SRC" "$REPOS" | grep -v "CVS"
