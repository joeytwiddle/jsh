#!/usr/bin/env bash

# This lists all attempted installs, and some other things, with no consideration for whether the install succeeded or the package even existed!
grep "Running 'pacman -S" /var/log/pacman.log
