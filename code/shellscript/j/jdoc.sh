( 

  if test "$1" = ""; then

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
    TABCHAR=`echo -e "\011"`
    cd $JPATH/tools/
	 higrep "\<$1\>" -C2 *
  fi

)
