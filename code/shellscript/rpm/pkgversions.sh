for X in "$@"; do
if test "$1" != "$*"
then echo "$X:"
fi
apt-cache showpkg "$X" 2>/dev/null |
drop 2 |
tostring "" |
# Why doesn't this line work?!
sed 's+(security[^)]*_dists_\([^_]*\)_[^)]*)+(security:\1)+g' |
sed 's+([^)]*_dists_\([^_)]*\)_main_[^)]*)+(\1)+g' |
sed 's+^\(.*\)(/var/lib/dpkg/status)\(.*\)$+\1\2 '`cursecyan`'[Installed]'`cursenorm`'+' |
# Following two equivalent:
sed 's+/var/lib/apt/lists/++g'
# sed 's+([^)]*/\([^)]*\))+(\1)+g'
if test "$1" != "$*"
then echo
fi
done
