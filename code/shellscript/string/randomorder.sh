#!/bin/sh
# jsh-ext-depends: sort
# jsh-depends: afterfirstall

## TODO: if randomorder is imported as a function into another script,
##       and used more than once,
##       then its seed remains the same.  :-(

# #!/usr/local/bin/zsh
# /usr/bin/nawk '

SEED=`date +%s`

awk '
  BEGIN {
    FS="\n";
    // srand('$$');
    srand('"$SEED"');
  }
  {
    printf(int(100001*rand()));
    printf(" ");
    printf("%s",$1);
    printf("\n");
  }
' "$@" |
  sort -k 1 |
  afterfirstall " "
