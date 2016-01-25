#!/bin/sh

# Maybe just maybe I should use python when I have to deal with numbers.

adjustment_percent="$1"

if which xbacklight >/dev/null
then
	# Do not use the provided value; instead adjust exponentially, relative to current brightness
	if [ "$adjustment_percent" -gt 0 ]
	then adjustment_direction="+"
	else adjustment_direction="-"
	fi
	adjustment_magnitude=$(echo "$adjustment_percent" | sed 's/^[+-]//')
	current_brightness=$(xbacklight -get)
	#actual_adjustment="${adjustment_direction}$(echo "define max (a,b) { if (a>b) { return a; } else { return b; } } max($current_brightness * 0.3, 1)" | bc)"
	actual_adjustment="${adjustment_direction}$(echo "define max (a,b) { if (a>b) { return a; } else { return b; } } scale=2; max($current_brightness * $adjustment_magnitude / 5.0, 1)" | bc)"
	#actual_adjustment="$(echo "$current_brightness * $adjustment_magnitude / 5" | bc)"
	#if [ "$actual_adjustment" -lt 1 ]
	#then actual_adjustment=1
	#fi
	#actual_adjustment="$adjustment_direction$actual_adjustment"

	xbacklight -inc "$actual_adjustment"
	current=$(xbacklight -get | grep -o '^[^.]*')
	if [ "$current" -lt 1 ]
	then xbacklight = 1
	fi
	exit
fi

min_brightness_percent=10

current_brightness=$(xrandr --current --verbose | grep Brightness: | head -n 1 | takecols 2)
current_brightness_percent=$(calc "$current_brightness" '*' 100 | sed 's+\..*++')

[ -z "$current_brightness_percent" ] && current_brightness_percent=0

# Passing -5 is fine, passing +5 is not!
adjustment_percent=$(echo "$adjustment_percent" | sed 's/^+//')

new_brightness_percent=$(calc "$current_brightness_percent" + "$adjustment_percent" | sed 's+\..*++')
#new_brightness_percent=$((current_brightness_percent + adjustment_percent))

if [ "$new_brightness_percent" -lt "$min_brightness_percent" ]
then new_brightness_percent="$min_brightness_percent"
elif [ "$new_brightness_percent" -gt 100 ]
then new_brightness_percent=100
fi

new_brightness=$(calc -s 2 "$new_brightness_percent" / 100)

[ -z "$new_brightness" ] && new_brightness=1.0

first_output=$(xrandr | grep -v "^Screen " | head -n 1 | takecols 1)

#xrandr --output "$first_output" --brightness "$new_brightness"

# User may want to reduce the top white, but not reduce the lower colours:
gamma=1.0
#if [ "$new_brightness_percent" -lt 91 ]
#then gamma=1.1
#fi
#if [ "$new_brightness_percent" -lt 71 ]
#then gamma=1.2
#fi
#if [ "$new_brightness_percent" -lt 51 ]
#then gamma=1.3
#fi
#if [ "$new_brightness_percent" -lt 31 ]
#then gamma=1.4
#fi
#if [ "$new_brightness_percent" -lt 11 ]
#then gamma=1.5
#fi
rgamma=$gamma
ggamma=$gamma
bgamma=$gamma
rgamma=1.0
ggamma=1.0
bgamma=1.0
xrandr --output "$first_output" --brightness "$new_brightness" --gamma "$rgamma:$ggamma:$bgamma"

# An alternative method is to read from $bl/actual_brightness, crop to $bl/bl_power and $bl/max_brightness, and set $bl/brightness, where bl=/sys/class/backlight/intel_backlight, however on my current machine this requires Ubuntu.
