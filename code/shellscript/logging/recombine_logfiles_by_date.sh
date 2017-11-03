#!/usr/bin/env bash

# Sometimes people save stdout and stderr to two different logfiles, but you want to read the combined log.
# (This could also apply to logfiles from different processes/servers, if you want to read them interlaced.)
# If the logfiles have a date that we can sort by, then we could sort the lines, but there is one problem.
# If any of the lines break onto multiple lines, then the broken lines will not have dates, and so sorting will separate those lines from their correct position.
# This script attempts resolves that issue.

# Current approach: merge broken lines back onto the first line, do the sorting, and then break the merged lines back off again.
# To do this, we need a regexp that can detect whether a line has a date on it, or not.

cat "$@" |
# Add `>` or `.` to the start of each line, depending whether it matches the date regexp or not (in this case the date regexp is "^2017"
sed 's+^+. + ; s+^. 2017+> 2017+ ; s+\\+\\+g ; s+$+\\n+' |
# Merge all lines beginning with `.` onto the line above
# (Actually merges all lines, and then adds newlines back in for the `>` lines)
tr -d '\n' | sed 's+\\n> +\
+g' |
# Sort the lines according to the dates (you may need a more complex sort depending on your dateformat)
sort |
# Split those `\n. ` lines onto multiple lines again
sed 's+\\n. +\
+g'

# Alternative approach: we could copy the dates from the first line onto any broken lines below them, and then sort without merging.  Afterwards we could remove the added dates if we want (using a marker).  Note: We would need to do either a stable sort (selecting only a few fields to sort by) or number each line in a group, so that they come out in the same order at the end.

