#!/usr/bin/env bash

# Note: Before running, we need to download the file indexes, by running:
#     sudo pacman -Fy

pkg_name="$1"

pacman -Fl "$pkg_name"
