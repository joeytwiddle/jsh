# echo "grep $*" 1>&2
PID=$$
# echo "-$PID"
# --cols 65535 
env COLUMNS=65535 myps -A | ungrep "grep" | grep $* | grep -v " $PID "
