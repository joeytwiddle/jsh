#!/bin/bash
# See also: focus-or-run
wmctrl -x -a "$1" || $2
