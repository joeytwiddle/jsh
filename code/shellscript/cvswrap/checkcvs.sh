REPOS="$1"

SRC=`absolutepath "$REPOS"`

echo "Comparing your $SRC against a fresh cvs checkout of $REPOS"

mkdir -p /tmp/ckout
'cd' /tmp/ckout
cvs checkout "$REPOS" > /dev/null 2>&1

comparedirscksum "$SRC" "$REPOS" | grep -v "CVS"

'rm' -rf "/tmp/ckout"
