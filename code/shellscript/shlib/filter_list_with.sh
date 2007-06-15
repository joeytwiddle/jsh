while read LINE
do "$@" "$LINE" && echo "$LINE"
done
