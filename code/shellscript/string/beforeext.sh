#!/bin/sh
EXT="$1"

'ls' *".$EXT" |
sed "s+\.$EXT$++"
