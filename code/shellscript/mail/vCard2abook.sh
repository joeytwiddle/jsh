## Note: whilst abook entries usually start with [n],
## the unnumbered generated entries are successfully
## read by abook=0.4.16-1
cat "$1" |
egrep "(^FN:|^EMAIL;|nickname:|NICKNAME:)" |
sed "
s+^FN:+\\
name=+
s+EMAIL;INTERNET:+email=+
s+.*\(nickname\|NICKNAME\):[ ]*+nick=+
"
