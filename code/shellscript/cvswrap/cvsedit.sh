#!/bin/sh
## Makes all of your cvs files in current/specified folder writeable, because if you "cvs commit" a file or files it write-locks it.

# this-script-does-not-depend-on-jsh: edit

cvs edit "$@" >/dev/null 2>&1 || cvs edit &
