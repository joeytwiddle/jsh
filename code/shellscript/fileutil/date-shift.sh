#!/bin/sh
set -e

shift_amount="$1"
shift

shift_amount="$(echo "$shift_amount" | sed '
  s/^\+/+ /
  s/^\-/- /
  s/\([0-9 ]\)s$/\1 seconds/
  s/m$/ minutes/
  s/h$/ hours/
  s/d$/ days/
  s/y$/ years/
')"

for file
do
    # Your locale (e.g. LC_TIME=en_GB.UTF-8) might return a date which date cannot parse back in!
    # To fix that, we should switch to the standard locale (LC_TIME=C) when we print out a date.

    date="$(LC_TIME=C date -r "$file")"

    new_date="$(LC_TIME=C date -d "$date $shift_amount")"

    verbosely touch -d "$new_date" "$file"
done
