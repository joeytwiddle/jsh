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
    printf($1);
    printf("\n");
  }
' $* |
  sort -k 1 |
  afterfirstall " "
