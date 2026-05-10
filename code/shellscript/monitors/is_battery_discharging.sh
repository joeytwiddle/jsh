#!/usr/bin/env bash
set -e

case "$(cat /sys/class/power_supply/BAT0/status 2>/dev/null || true)" in
    Charging|Full)
        exit 1
        ;;
    Discharging)
        exit 0
        ;;
    *)
        ;;
esac

busctl_result="$(busctl get-property org.freedesktop.UPower /org/freedesktop/UPower org.freedesktop.UPower OnBattery 2>/dev/null || true)"
if [ "$busctl_result" = "b true" ]
then exit 0
elif [ "$busctl_result" = "b false" ]
then exit 1
fi

# My system didn't have this file, so not very useful
if [ -f /sys/class/power_supply/AC/online ]
    if [ "$(cat /sys/class/power_supply/AC/online 2>/dev/null)" = "0" ]
    then exit 0
    else exit 1
    fi
fi

if which acpi >/dev/null 2>&1
then
    if acpi -a | grep -q "on-line"
    then exit 1
    else exit 0
    fi
fi

# upower -d show lots of info, but naive interrogation can be misleading
# Simple heuristics which did not work:
# - Grepping for 'online' can return a false-positive even when on battery
# - Grepping for 'discharging' can report wireless devices (e.g. external keyboard) which is not what we are trying to detect!
#if which upower >/dev/null 2>&1
#then
#    if upower -d | grep -q 'discharging'
#    then exit 0
#    else exit 1
#    fi
#fi
