#!/bin/sh
## Makes all of your cvs files in current/specified folder writeable, because if you "cvs commit" a file or files it write-locks it.

# jsh-depends-ignore: edit

## Might not always work?
cvs edit "$@" >/dev/null 2>&1 || cvs edit

## Should do something:
## We avoid this if we can, since I have a CVS/ folder in my ~
# find . -type f | grep -v /CVS/ |
# while read f
# do chmod ug+rw "$f"
# done

