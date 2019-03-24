# For those unfortunate situations where you have run out of disk-space, deleted a huge file to attempt to reclaim it, and then realised that the file was still opened by some process, and so you don't have the space back and you can't truncate the file!
find /proc/*/fd -ls | grep  '(deleted)'

# Alternatives:
#lsof -a +L1
#lsof -nP | grep '(deleted)'
# The output from lsof shows the $fd (file descriptor) as the fourth field.  You may have to strip off the trailing 'u'.

# Now you can truncate such a file with:
#: > "/proc/$pid/fd/$fd"
