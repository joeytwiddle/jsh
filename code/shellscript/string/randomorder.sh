#!/bin/sh
# jsh-ext-depends: sort
# jsh-depends: afterfirstall

# #!/usr/local/bin/zsh
# /usr/bin/nawk '

awk '
  BEGIN {
    FS="\n";
    srand('$$');
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
