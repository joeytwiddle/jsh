## Appears stable =)

NL="
"
for X
do
  DIR=`dirname "$X"`
  FILE=`basename "$X"`
  # SWAPS=`countargs $DIR/.$FILE.sw?`
	## TODO: The leading . is not necessary if file is a .file
  SWAPS=` find "$DIR"/ -maxdepth 1 -name ".$FILE.sw?" | countlines `
  if test $SWAPS -lt 1
  then echo "No swapfiles found for $X"
  elif test $SWAPS -gt 1
  then echo "More than one swapfile found for $X.  TODO: can recover by referring to swapfile directly."
  else

    N=1
    while test -e "$X.recovered.$N"
    do N=`expr $N + 1`
    done
    if vim +":w $X.recovered.$N$NL:q" -r "$X" &&
       test -f "$X.recovered.$N"
    then
      echo "Successfully recovered to $X.recovered.$N"
      ## Could probably delete swapfile now, if we only knew its name!  (Use del)
      if cmp "$X" "$X.recovered.$N" > /dev/null
      then
        echo "Recovered swap is identical to original, recommend removing with:"
        rm "$X.recovered.$N" ## remove temp file
        ## Now if we are really confident about this script, we could
        ## delete the swapfile, or get vim to.
        cursecyan
      else
        echo "Not identical, but recovered, so you can remove the swapfile with:"
        ## Again, if the recovered file exists and is not empty,
        ## then its pretty likely the swapfile is redundant, and can be removed.  =)
        cursecyan
        # vimdiff "$X" "$X.recovered.$N"
        echo "vimdiff $X $X.recovered.$N"
        echo "del $X.recovered.$N"
      fi
      # echo del $DIR/.$FILE.sw?
      echo del $DIR/.$FILE.swp
      cursenorm
    else
      echo "Some problem recovering swap file (for) $X"
    fi

  fi
done

## Doesn't work:
# vim +":recover
# :w tmp
# :q" "$1"
