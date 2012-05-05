## @long_overdue

unique=/tmp/duskdiff.$$
oldDusk=$unique.old
newDusk=$unique.new

memo -t '100 years' dusk | striptermchars | sort -k 2 > "$oldDusk"

rememo dusk | striptermchars | sort -k 2 > "$newDusk"

# diff "$oldDusk" "$newDusk" | diffhighlight
jdiffsimple "$oldDusk" "$newDusk"

# rm -f "$oldDusk" "$newDusk"
del "$oldDusk" "$newDusk"

