## Colors output on stderr in red, leaves stdout the normal white.
## TODO: make it possible for this to always run when user runs an interactive shell command.

CURSENORM=`cursenorm`
CURSEREDBOLD=`cursered;cursebold`

(
	"$@" |
	while read X
	do printf "%s\n" "$CURSENORM$X"
	done
) 2>&1 |

while read X
do printf "%s\n" "$CURSEREDBOLD$X$CURSENORM"
done
