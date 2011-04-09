## Returns 0 if stdout is to a terminal (pts or tty),
## or non-0 if stdout is another type of stream.
tty 0>/dev/stdout >/dev/null 2>&1
## Stolen from /usr/share/fish/functions/isatty.fish
