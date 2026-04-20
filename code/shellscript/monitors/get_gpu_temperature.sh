#!/bin/sh

# Show the highest GPU temperature in degrees Celsius, as an integer.
# On Linux: uses lm-sensors ("sensors" command), reads "temp1:" lines.
# On macOS: no non-sudo way to read GPU temperature (powermetrics requires
# sudo), so silently prints nothing.

case "$(uname)" in
    Darwin)
        # Intentionally no output on macOS.
        :
        ;;
    *)
        # Original Linux implementation.
        sensors 2>/dev/null | grep '^temp1:' | takecols 2 | sort -n | tail -n 1 | sed 's/^+\([0-9]*\)\..*$/\1/'
        ;;
esac
