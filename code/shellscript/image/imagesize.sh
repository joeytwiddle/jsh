for X in $*; do
  imageinfo "$X" | head -n 1 | after "$X " | beforefirst ' ' | beforefirst "+"
  # | tail -n 1 | beforefirst ' '
  # | takecols 2
done
