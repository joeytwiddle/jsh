# If making coarse measurements, try not to affect processor too much (Heisenberg)
nice="nice -n 6"

# $nice jwatch -oneway cpufreq-info | $nice dateeachline

# $nice jwatchchanges -fine -n 15 eval "cpufreq-info  |  fromline '(available|current)'"

# But for fine measurements (1.0s), and with datediffeachline, nice will be too slow!
nice=""
$nice jrep -delay 0.98 cpufreq-info | $nice grep --line-buffered "current CPU" | $nice removeduplicatelinesadj | $nice datediffeachline

