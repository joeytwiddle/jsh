awk '
  BEGIN {
    FS="\n";
    srand();
  }
  {
    printf(int(100001*rand())" "$1"\n");
  }
' $* |
  sort -k 1 |
  head -n 1 |
  afterfirst " "
