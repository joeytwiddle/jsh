## Useful in scripts:
find . -type f -printf "%A@ %p\n" | sort -n -k 1 |
dropcols 1 |

## Pretty-print (change format!) for user:
foreachdo dar -ld

