NUMBYTES="$1"

dd bs=1 count="$NUMBYTES" 2>/dev/null
## TODO: should check specified number were successfully copies; exit with error if not.  (Or maybe not?!  What does head (lines) do?)

## TODO: bs=1 is inefficient for any long stream (see optimdd)
