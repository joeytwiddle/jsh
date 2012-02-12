PREPEND_STRING="$1"

sed "s^$1g"

# while IFS= read LINE
# # do echo "$PREPEND_STRING$LINE"
# do printf "%s\n" "$PREPEND_STRING$LINE"
# done
