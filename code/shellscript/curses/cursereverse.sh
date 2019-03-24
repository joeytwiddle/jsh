#!/bin/sh
# None of these work on macOS
#setterm -reverse
#tput -rev
#tput smso
# smso is "stand-out mode" which actually performs reverse (swaps fg/bg colors)
# This one works on Linux and macOS
echo ^[[7m
