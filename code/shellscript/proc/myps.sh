# jsh-ext-depends-ignore: time
# jsh-depends-ignore: pid
## pcpu and pmem are used by wotgobblecpu and wotgobblemem, but are variable, so are not useful for watching!
if [ "$1" = -novars ]
then
	shift
	ps -o time,ppid,pid,nice,user,args $@
else
	ps -o time,ppid,pid,nice,pcpu,pmem,user,args $@
fi
# ps -o time,pcpu,pmem,pid,user,comm $@
# ps -o "(%x %C) %p %u : %a" $@
