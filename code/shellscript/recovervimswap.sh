## Appears stable =)

NL="
"
for X
do
  N=1
  while test -e "$X.recovered.$N"
  do N=`expr $N + 1`
  done
  if vim +":w $X.recovered.$N$NL:q" -r "$1" &&
     test -f "$X.recovered.$N"
  then
    echo "Successfully recovered to $X.recovered.$N"
    if cmp "$X" "$X.recovered.$N" > /dev/null
    then
      echo "BUT IDENTICAL to original, so REMOVING."
      rm "$X.recovered.$N"
      ## Now if we are really confident about this script, we could
      ## delete the swapfile, or get vim to.
    else
      echo "Not identical."
      echo "If not empty then its pretty likely the swapfile is redundant =)"
      cursecyan
      vimdiff "$X" "$X.recovered.$N"
      echo "vimdiff $X $X.recovered.$N"
      echo "del $X.recovered.$N"
      echo del `dirname "$X"`/.`basename $X`.sw?
      cursenorm
    fi
  else
    echo "Some problem recovering swap file (for) $X"
  fi
done

## Doesn't work:
# vim +":recover
# :w tmp
# :q" "$1"
