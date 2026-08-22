xrandr --output $(xrandr --query | grep " connected" | head -n 1 | cut -d ' ' -f1) --gamma 1.3
