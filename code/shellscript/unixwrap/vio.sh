#!/bin/sh
## Redundant; use vim -
"$@" > $JPATH/tmp/tmp.txt
vim $JPATH/tmp/tmp.txt
