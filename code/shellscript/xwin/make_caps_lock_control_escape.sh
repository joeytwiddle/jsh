#!/bin/bash

pkill -u "$UID" xcape
setxkbmap -option 'caps:ctrl_modifier'
xcape -t 150 -e 'Caps_Lock=Escape'
#xcape -e 'Caps_Lock=Escape;Control_L=Escape;Control_R=Escape'

# To undo:
#     killall xcape
#     setxkbmap -option
