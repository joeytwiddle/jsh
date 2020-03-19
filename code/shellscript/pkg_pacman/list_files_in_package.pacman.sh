#!/usr/bin/env bash

# Note: Before running, we need to download the file indexes, by running:
#     sudo pacman -Fy

pkg_name="$1"

# Basic
#pacman -Fl "$pkg_name"

# Fast (memoed) and cleaned up
memo pacman -Fl "$pkg_name" |
dropcols 1 |
prepend_each_line '/'
