# jsh-depends: cursebold cursecyan cursegrey cursewhite cursenorm
# jshinfo "$@"
# echo "`curseyellow;cursebold`[EXEC]`cursecyan` $PWD %`cursegrey` $*`cursenorm`" >&2
# echo "`curseyellow`[EXEC]`cursecyan` %`cursegrey` $*`cursenorm`" >&2

## xttitle was bad; adding stuff to streams which scripts were using (verbosely); but tty check seems to have fix this ; no it hasn't :s (e.g. was steal_package_from_chroot.sh)
# tty -s && xttitle "# $* [$PWD]" ## mmm; better than nothing, for bash, since i have not yet found a way to run xttitle automatically whenever a new user-command is executed

# tty -s || SHOW_IO=" (<stdin)"

## TODO: it would really be rather nice if verbosely surrounded the arguments which contain spaces with qoutes when it prints them.
[ "$NOEXEC" ] || echo "`cursecyan;cursebold`[EXEC]`cursewhite` %`cursegrey` $*`cursenorm`$SHOW_IO" >&2

if [ "$HIGHLIGHTSTDERR" ]
then highlightstderr "$@"
else "$@"
fi
ERR="$?"

## This can be useful sometimes, when the statement is expected to succeed, but this is not always the case!
# [ "$ERR" = 0 ] || [ "$DONT_REPORT_FAILURE" ] || echo "`curseyellow;cursebold`[`cursered;cursebold`EXEC`curseyellow;cursebold`]`cursewhite` !`cursered;cursebold` $* `curseyellow`had error `cursered;cursebold`$ERR`cursenorm` (`tty`)" >&2

reply $ERR

