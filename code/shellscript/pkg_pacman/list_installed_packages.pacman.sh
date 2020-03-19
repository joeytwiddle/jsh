#!/usr/bin/env bash

pacman -Qn | grep -e "$*"

# To list packages by searching descriptions:
#pacman -Qs "$*"
