# this-script-does-not-depend-on-jsh: pid
ps --no-headers -o ppid,pid,args "$@"
