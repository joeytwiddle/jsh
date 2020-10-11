#!/usr/bin/env bash
set -e

# You can run this from the commandline, but I prefer to run it from a cronjob:
#
#     */2 * * * *        env DISPLAY=:0 nice ionice /home/joey/jsh/tools/jflux

low=7
high=55

now="$(date +%s)"
today="$(date +%F)"
midnight=$(date -d "$today 0" +%s)
seconds_since_midnight="$((now - midnight))"

range="$((high - low))"

one_hour="$((60 * 60))"

# Fade down from midnight to 1am
#if [ "$seconds_since_midnight" -lt 3600 ]
#then thru="$((100 * (3600 - seconds_since_midnight) / 3600))"
# Stay low during the night
if [ "$seconds_since_midnight" -lt "$((6 * one_hour))" ]
then thru=0
# Fade up from 6am to 7am
elif [ "$seconds_since_midnight" -lt "$((7 * one_hour))" ]
then thru="$((100 * (seconds_since_midnight - 6 * one_hour) / 3600))"
# Fade down from 11pm to midnight
#elif [ "$seconds_since_midnight" -gt "$((23 * one_hour))" ]
#then thru="$((100 - 100 * (seconds_since_midnight - 23 * one_hour) / 3600))"
# Fade down from 10pm to midnight
elif [ "$seconds_since_midnight" -gt "$((22 * one_hour))" ]
then thru="$((100 - 100 * (seconds_since_midnight - 22 * one_hour) / 7200))"
# Stay high during the day
else thru=100
fi

brightness="$((low + range * thru / 100))"

# Between midnight and 6am, dim the display right down, if the machine is idle
# Or if a certain process is running: && pgrep ___ >/dev/null
if [ "$seconds_since_midnight" -lt "$((6 * one_hour))" ] && ( ! which xprintidle >/dev/null 2>&1 || [ "$(xprintidle)" -gt "180000" ] )
then brightness=1
fi

# We only set it if the numbers differ.  This prevents repeated unnecessary calls to xbacklight from keeping the screen awake.  (My system seemed to think the machine was still in use, so the screen never turned off.)
current="$(xbacklight -get | sed 's+\..*++')"
if [ "$current" != "$brightness" ]
then xbacklight -set "$brightness"
fi
