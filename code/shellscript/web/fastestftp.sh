for X in `ftpsearch "$@"`; do
  showpingtime "$X" &
done
