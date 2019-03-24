#!/bin/sh

curl -s http://wttr.in/"$*" # | head -7 | tail -5
