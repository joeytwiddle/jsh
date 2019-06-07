lsof -n -S 2 | cut -d ' ' -f 1 | uniq -c | sort -n -k 1 | tail -n 15
