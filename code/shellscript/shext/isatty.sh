#!/bin/bash
## If you want to check if stdout is connected directly to a terminal, then use the bash check:
[ -t 1 ]
# There is also -p to check if the FD is connected to a pipe.  http://serverfault.com/questions/156470/testing-for-a-script-that-is-waiting-on-stdin
# DISADVANTAGE: The user may be simply piping to |more, in which case we may still want to add color to the output.  But piping to |more will cause the above to return false.
# Uhhhh it will also cause the below to return false.  :P

## No shebang required
## DO NOT USE THIS to decide whether to strip colors!  It's probably not what you want.  It returns success even if you are piping to grep or xargs.  Maybe it is what you want.  It depends what you want.  When does it return false?  When the data is going into a var, not direct to stdout?
## Returns 0 if stdout is to a terminal (pts or tty),
## or non-0 if stdout is another type of stream.
#tty 0>/dev/stdout >/dev/null 2>&1
## Stolen from /usr/share/fish/functions/isatty.fish

## UNRELATED but I thought it was worth noting:
## If you have lost your tty (e.g. the app which calls us has stolen it) but you want to break through to the tty anyway, to interact with the user, you can do:
## exec < /dev/tty
## From: https://github.com/eggsy84/GitDryRunMerge/blob/master/post-commit

