# jsh-depends: cursebold cursecyan cursegrey cursewhite cursenorm
# jshinfo "$@"
# echo "`curseyellow;cursebold`[EXEC]`cursecyan` $PWD %`cursegrey` $*`cursenorm`" >&2
# echo "`curseyellow`[EXEC]`cursecyan` %`cursegrey` $*`cursenorm`" >&2
echo "`cursecyan;cursebold`[EXEC]`cursewhite` %`cursegrey` $*`cursenorm`" >&2
"$@"
