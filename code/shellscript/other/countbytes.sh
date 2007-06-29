# jsh-ext-depends: sed
# dd of=/dev/null bs=1 2>&1 | head -n 2 | tail -n 1 | sed 's/+.*//'

# TOEVAL=`dd of=/dev/null bs=1024 2>&1 | head -n 2 | tail -n 1 | sed "s/+/ '*' 1024 + / ; s/ records.*//"`
# eval "expr $TOEVAL"

# dd of=/dev/null bs=1024 2>&1 | tail -1 | sed 's+ .*++'
wc -c
