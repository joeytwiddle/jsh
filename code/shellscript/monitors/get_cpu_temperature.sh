#!/bin/sh

# Show the highest core CPU temperature in degrees Celsius, as an integer.
# On Linux: uses lm-sensors ("sensors" command).
# On macOS: uses osx-cpu-temp if installed (brew install osx-cpu-temp), or
# istats if installed (gem install iStats). Otherwise silently prints nothing
# — Apple Silicon has no non-sudo alternative.

case "$(uname)" in
    Darwin)
        # osx-cpu-temp output looks like "55.9°C" — strip decimals and the unit.
        if command -v osx-cpu-temp >/dev/null 2>&1
        then osx-cpu-temp 2>/dev/null | sed 's/\..*//'
        elif command -v istats >/dev/null 2>&1
        then istats cpu temp 2>/dev/null | sed -n 's/.*: *\([0-9][0-9]*\)\..*/\1/p'
        fi
        ;;
    *)
        # Original Linux implementation.
        sensors 2>/dev/null | grep '^Core [0-9]*:' | takecols 3 | sort -n | tail -n 1 | sed 's/^+\([0-9]*\)\..*$/\1/'
        ;;
esac
