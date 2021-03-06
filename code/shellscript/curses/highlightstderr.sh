#!/bin/sh
## Runs the command you provide, making standard error messages appear in red.
## Added ERRFILE fix to return exit code.

## BUG: sometimes, e.g. if stdout has been stalled, stderr lines will appear out of place, don't highlight and use 2>&1 instead

## CONSIDER: make it possible for this to always run when user runs an interactive shell command.

## TODO: Surely this will be needed sooner or later.  When it is, test it!
if [ "$ALREADY_HIGHLIGHTING_STDERR" ]
then
	"$@"
	exit
else
	# export ALREADY_HIGHLIGHTING_STDERR=will_be_soon
	## I wonder if highlighting X's stderr might export this to all X's child xterm's, who should in fact have their own tty's and will need their stderr's to be highlighted separately.  This might help us to track that:
	export ALREADY_HIGHLIGHTING_STDERR="tty=`tty` com=$* display=$DISPLAY user=$USER($UID)"
fi

CURSENORM=`cursenorm`
CURSEREDBOLD=`cursered;cursebold`
CURSERED=`cursered`
CURSEYELLOW=`curseyellow`
CURSEYELLOWBOLD=`curseyellow;cursebold`

exec 3>&1 ## save stdout in 3 (make 3 point at original stdout)

## Send stderr to new (local,piped) stdout &1, and stdout to &3 (original stdout)
# "$@" 2>&1 >&3 |
ERRFILE=/tmp/highlightstderr_errfile.$$
( "$@" ; echo "$?" > "$ERRFILE" ) 2>&1 >&3 |

## Send the highlighted output back to stderr (&2).

# while read X
# do
	# printf "%s\n" "$CURSERED$X$CURSENORM"
	# # printf "%s\r" "$CURSEREDBOLD$X$CURSENORM" ; printf "%s\r" "$CURSEYELLOW$X$CURSENORM" ; printf "%s\n" "$CURSERED$X$CURSENORM"
	# # printf "%s\n" "$CURSEYELLOWBOLD""!x!"" $CURSEREDBOLD$X $CURSEYELLOWBOLD""!x!""$CURSENORM"
# done >&2

# sed -u "s+.*+$CURSERED\0$CURSENORM+" >&2
sed -u "s+^+$CURSEREDBOLD+ ; s+$+$CURSENORM+" >&2
## I need bold red for my little xterms, or I can't quite make out the text of the error message!
## Actually they are both unreadable, bold is so fat it loses information, thin is just a bit too dark!  Change xterm's default red to a bit brighter (some g+b)?

## TODO: only affect non-coloured lines; lines with colour-coding (at the start (and norm at the end?)) are not highlighted or added to
# Doesn't work: sed -u "s+^[^`printf "\033["`].*+$CURSERED\0$CURSENORM+" >&2 ## send the highlighted output back to stderr

printf "\033[00;36m" >&2 ## Reset color - grey for joey ?

## NOTE: The redirection example I used also added 3>&- at the end of both the "$@" and sed lines, but this appears to me to be superflous.

exec 3>&- ## Close fd 3 (is this neccessary? we are unlikely to use it, even if this script is used as a function).

ERRNUM=`cat "$ERRFILE"` ; rm -f "$ERRFILE"
exit $ERRNUM




# Another way of doing this might be...

# Child processes inherit open file descriptors. This is why pipes work. To prevent an fd from being inherited, close it.
# Redirecting only stderr to a pipe.

exec 3>&1                              # Save current "value" of stdout.
ls -l 2>&1 >&3 3>&- | grep bad 3>&-    # Close fd 3 for 'grep' (but not 'ls').
#              ^^^^   ^^^^
exec 3>&-                              # Now close it for the remainder of the script.

# Thanks, S.C.

