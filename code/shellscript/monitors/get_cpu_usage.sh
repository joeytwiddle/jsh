# This gets the average cpu usage since boot:
#awk '/cpu / {usage=($2+$4)*100/($2+$4+$5)} END {printf "%i\n", usage}' /proc/stat

# This is too slow!
#top -bn2 | grep "Cpu(s)" | \
           #sed "s/.*, *\([0-9.]*\)%* *id.*/\1/" | \
           #awk '{print 100 - $1}'

# mpsttat or sysstat are better ways of doing this.

# In the meantime, let's show the cpu frequency instead.
# We head instead of tail, to show the core with the lowest frequency.  I find this value has richer variation, because one of my cores is always at max (possibly it has stepped up to run the huge pipe below!).
cpufreq-info | grep "current CPU frequency" | takecols 5 6 | sort -n -k 1 | head -n 1 | sed 's+^\(...\)[^ ]* *\(.\).*+\1\2+'
