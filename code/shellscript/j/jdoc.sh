if test "$1" = ""; then

  echo "jdoc <command>"
  echo "  will show you the documentation for the command"
  echo "  and if requested usage of / dependencies on that command in all shellscripts"

else

  LINKTOCOM="$JPATH/tools/$1"

  if test -f "$LINKTOCOM"; then

    (
      echo `justlinks "$LINKTOCOM"`
      echo "::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
      cat "$LINKTOCOM"
      echo
      echo "::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
    ) | more

  else

    jman "$@"
    info "$@"

  fi

  echo
  echo "Press <Enter> to see usage of/dependencies on $1"
  read KEY
  if test "$KEY" = ""; then
    TABCHAR=`echo -e "\011"`
    cd $JPATH/tools/
    higrep "\<$1\>" -C2 *
  fi

fi
