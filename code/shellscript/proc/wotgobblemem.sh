# myps -A | sort -n -k 6 | tail "$@"
ps -o time,ppid,pid,nice,pcpu,pmem,user,comm -A | sort -n -k 6 | tail -15 "$@"
