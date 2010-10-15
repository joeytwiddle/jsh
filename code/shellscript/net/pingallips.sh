#!/bin/sh
# echo "" > ping.tmp
forall -stealth in "$@" do "showpingtime %w" # " >> ping.tmp &"
# tail -f ping.tmp
