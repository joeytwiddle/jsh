awk '
  BEGIN {
    FS="\n";
    srand();
  }
  {
    printf(int(100001*rand())" ");
		printf($1);
		printf("\n");
  }
' $* |
  sort -k 1 |
  head -n 1 |
  afterfirst " "
