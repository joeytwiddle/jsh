#!/bin/sh
# jsh-depends: randomorder

randomorder "$@" | head -n 1

# awk '
  # BEGIN {
    # FS="\n";
    # srand();
  # }
  # {
    # printf(int(100001*rand())": ");
    # print $1;
  # }
# ' "$@" | sort -k 1 | head -n 1 | afterlastall ": "
