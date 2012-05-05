#!/bin/sh

# cvs update "$@" 2>&1 |
# grep -v "^? " |
# grep -v "^cvs update: Updating " |
# grep -v "^cvs server: Updating "

cvs -z 9 -q update "$@" |
grep -v "^\? " | ## BUG: returns non-zero exit code, if the update had nothing to output
sed 's+^M +M locally Modified +
     s+^U +U          Updated +
     s+^P +P          Patched +
     s+^C +C       Conflicts! +
'

## BUG: With args "-AdP <dir>" cvsedit "$@" doesn't target the target dir, but cwd!
cvsedit # "$@"

