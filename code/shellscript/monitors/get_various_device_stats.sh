#!/bin/sh

# Produce a compact one-line summary of system stats for e.g. a tmux status
# bar: CPU frequency, 1-minute load average, and CPU/GPU temperatures.
#
# Each piece is omitted entirely — separators and all — when the source is
# unavailable or produces no value, so nothing stale or blank is ever shown.

out=""
add() {
    [ -n "$1" ] || return 0
    if [ -z "$out" ]
    then out="$1"
    else out="$out $1"
    fi
}

# CPU frequency
if command -v get_cpu_frequency >/dev/null 2>&1
then add "$(get_cpu_frequency 2>/dev/null)"
fi

# 1-minute load average (Linux only — /proc/loadavg doesn't exist on macOS).
if [ -r /proc/loadavg ]
then add "$(sed 's+ .*++' /proc/loadavg)"
fi

# CPU / GPU temperatures. Show "NN°/NN°" when both are available, or just the
# one that is, or nothing if neither.
cpu=""
gpu=""
command -v get_cpu_temperature >/dev/null 2>&1 && cpu=$(get_cpu_temperature 2>/dev/null)
command -v get_gpu_temperature >/dev/null 2>&1 && gpu=$(get_gpu_temperature 2>/dev/null)
if [ -n "$cpu" ] && [ -n "$gpu" ]
then add "${cpu}°/${gpu}°"
elif [ -n "$cpu" ]
then add "${cpu}°"
elif [ -n "$gpu" ]
then add "${gpu}°"
fi

[ -n "$out" ] && printf '%s\n' "$out"
exit 0
