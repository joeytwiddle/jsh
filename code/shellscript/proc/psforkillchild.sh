# jsh-depends-ignore: pid
ps --no-headers -o ppid,pid,args "$@"
