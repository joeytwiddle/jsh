#!/bin/sh
if jwhich oaf-slay
then jshwarn "TODO: Should really call unj oaf-slay"
fi

## TODO: check with mykillps ; I think lines were truncated; do we need env COLUMNS=huge ?
mykill evolution wombat bonobo

findjob evol
