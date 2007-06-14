## Occasionally (in emergencies) I startx from within a screen.
## In these cases, I want X progs to "escape" the screen.
export STY=

# `jwhich startx` "$@" > $JPATH/logs/X-out.txt 2> $JPATH/logs/X-err.txt
# `jwhich startx` "$@" > $JPATH/logs/X-out.txt 2>&1
unj startx "$@" 2>&1 | tee /tmp/X.$$.log
