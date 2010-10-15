#!/bin/sh
## See listoverrides
cd $JPATH/tools
find . -type l | sed 's+\.\/++'  | while read X; do jwhich "$X" && echo "$X"; done
