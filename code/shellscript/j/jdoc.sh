if test "$1" = "" || test "$1" = "--help"; then

  echo "jdoc <command>"
  echo "  will show you the documentation for the command"
  echo "  and if requested usage of / dependencies on that command in all shellscripts"

else

  LINKTOCOM="$JPATH/tools/$1"

  if test -f "$LINKTOCOM"
  then

    dothis() {
    (
      barline() {
        echo "::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
      }
      ## If if appears to accept the --help argument, then just run it!
      ## (TODO: we could in fact attempt this on binaries!)
      # if grep '\-\-help' "$LINKTOCOM" > /dev/null
      if head -100 "$LINKTOCOM" | grep '\-\-help' > /dev/null
      then
        barline
        curseyellow
        echo "$LINKTOCOM --help"
        cursenorm
        barline
        $LINKTOCOM --help
        echo
      fi
      ## Show the script:
        barline
        cursecyan
        echo `justlinks "$LINKTOCOM"`
        cursenorm
        barline
        cat "$LINKTOCOM" |
        ## Pretty print it (I'd like to use a dedicated program with syntax highlighting)
        highlight "\#\#.*" yellow | ## for comments
        highlight "[^#]\# [A-Z].*" cyan | ## for lines likely to be a sentence
        highlight "	" blue | ## tabs
        sed 's+	+|--+g' | ## tabs
        cat
        echo
        barline
    ) | more
    }

    ## I really want to dothis in a bigwin (if X is running)
    dothis

  else

    jman "$@" # &&
    # info "$@"

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
