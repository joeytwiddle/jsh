#!/bin/sh
## jsh-help: Unlike seq's default mode, this will print huge integers in full.
## jsh-help: e.g.: diffcoms "seq 9999996 9999999" "intseq 9999996 9999999"

seq --format="%f" "$@" |
sed 's+\..*++'
