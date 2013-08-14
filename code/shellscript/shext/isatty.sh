## DO NOT USE THIS to decide whether to strip colors!  It's probably not what you want.  It returns success even if you are piping to grep or xargs.  If you want to check if stdout is connected directly to a terminal, then use the bash check [ -t 1 ]
# There is also -p to check if the FD is connected to a pipe.  http://serverfault.com/questions/156470/testing-for-a-script-that-is-waiting-on-stdin

## isatty
## Returns 0 if stdout is to a terminal (pts or tty),
## or non-0 if stdout is another type of stream.
tty 0>/dev/stdout >/dev/null 2>&1
## Stolen from /usr/share/fish/functions/isatty.fish
