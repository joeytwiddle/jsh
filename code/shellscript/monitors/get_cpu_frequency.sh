#!/bin/sh

# Show the CPU frequency in a compact form like "2.5G".
# On Linux: uses cpufreq-info, picks the core with the lowest frequency.
# On macOS Intel: uses sysctl hw.cpufrequency.
# On macOS Apple Silicon: there is no non-sudo way to read CPU frequency, so
# we silently print nothing.

case "$(uname)" in
    Darwin)
        hz=$(sysctl -n hw.cpufrequency 2>/dev/null)
        [ -z "$hz" ] && exit 0
        # Hz -> GHz with one decimal, e.g. 2500000000 -> "2.5G"
        awk -v hz="$hz" 'BEGIN { printf "%.1fG", hz/1000000000 }'
        ;;
    *)
        # Original Linux implementation.
        cpufreq-info 2>/dev/null | grep "current CPU frequency" | takecols 5 6 | sort -n -k 1 | head -n 1 | sed 's+^\(...\)[^ ]* *\(.\).*+\1\2+'
        ;;
esac
