REPOS="$1"

SRC=`absolutepath "$REPOS"`

mkdir -p /tmp/ckout
'cd' /tmp/ckout
cvs checkout "$REPOS" > /dev/null 2>&1

comparedirscksum "$SRC" "$REPOS" | grep -v "CVS"

'rm' -rf "/tmp/ckout"
