apt-cache showpkg "$1" 2>/dev/null |
drop 2 |
tostring "" |
sed 's+^\(.*\)(/var/lib/dpkg/status)\(.*\)$+\1\2 '`cursecyan`'[Installed]+' |
# Following two equivalent:
sed 's+/var/lib/apt/lists/++g'
# sed 's+([^)]*/\([^)]*\))+(\1)+g'
