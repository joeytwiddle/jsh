( 

  if test "$@" = ""; then

    echo "jdoc <command>"
    echo "  will show you the contents of $JPATH/tools/<command>"
    echo "  if you are lucky there might be some documentation in comments"

  else

    # find $JPATH/code/shellscript -name "$@" -o -name "$@.*" | grep -v "CVS"
    LINKTOCOM="$JPATH/tools/$1"

    if test -f "$LINKTOCOM"; then

      # echo "### "`justlinks "$@"`":"
      # echo "::::::::::::::"
      # echo `justlinks "$@"`
      # echo "::::::::::::::"
      # more "$@"
      (
        # echo "::::::::::::::"
        # echo "::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
        # echo "$1 -> "`justlinks "$@"`
        echo `justlinks "$LINKTOCOM"`
        # echo "::::::::::::::"
        echo "::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
        cat $LINKTOCOM
        echo
        echo "::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
      ) | more

    else

      jman "$@"
      info "$@"

    fi

  fi

  echo
  echo "Press <enter> to see usage of/dependencies on $1"
  read KEY
  if test "$KEY" = ""; then
    # echo "Usage of $1:"
    # grepcount $1 $JPATH/code/shellscript/ -r | afterlastall "/"
    # grep $1 $JPATH/tools/* 2>/dev/null
    # grep $1 $JPATH/tools/* 2>/dev/null |
    TABCHAR=`echo -e "\011"`
    cd $JPATH/tools/
    grep $1 * 2>/dev/null |
      egrep -v "^Binary file .* matches$" |
      sed "s|^|"`cursered``cursebold`"|;s|:|"`cursegrey`":$TABCHAR|" |
      # sed "s|^|"`cursecyan`"|;s|:|:"`cursegrey`"|" |
      # sed "s|$1|"`curseyellow`"$1"`cursegrey`"|g"
      highlight "$1" yellow
  fi

) # | more
