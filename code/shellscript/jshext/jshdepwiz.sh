## Get a script's dependencies

## Get a script's dependency data
## Generate a script's dependency data
## Compare and add new dependencies to tocheck list

## If a script needs dependencies checking, invoke the wizard.

## Suggested protocol: (but with only one # at start!)

## jsh-depends: <jsh_scripts>
## jsh-ext-depends: <real_progs>
## jsh-depends-ignore: ...
## jsh-ext-depends-ignore: ...
## jsh-depends-tocheck: ...
## jsh-ext-depends-tocheck: ...

## Note: instead of commenting out, the first two could be sourced and checked at runtime.

export INTERACTIVE=true
# export VIGILANT=true
export LAZY=true

function getrealscript () {
  jwhich inj "$1"
}

function extractdep () {
  if [ "$1" = -err ]
  then RETURN_ERROR=true; shift
  fi
  SCRIPT="$1"
  REALSCRIPT=`getrealscript "$1"`
  shift
  for DEPTYPE
  do
    RES=`
      cat "$REALSCRIPT" |
      grep "^# jsh-$DEPTYPE:"
    `
    # [ ! "$?" = 0 ] && [ "$RETURN_ERROR" ] && debug "failed to find jsh-$DEPTYPE in $SCRIPT" && return 1
    [ ! "$?" = 0 ] && [ "$RETURN_ERROR" ] && return 1
    echo "$RES" |
    afterfirst :
    # sed 's+^# jsh-$DEPTYPE:++'
  done
}

function adddeptoscript () {
  REALSCRIPT="$1"
  DEPTYPE="$2"
  DEP="$3"
  LINESTART="# jsh-$DEPTYPE:"
  FINDLINE=`grep "^$LINESTART" "$REALSCRIPT"`
  # DEPS=`grep "^$LINESTART" "$REALSCRIPT" | sed 's+^$LINESTART++'`
  DEPS=`grep "^$LINESTART" "$REALSCRIPT" | afterfirst : | tr '\n' ' '`
  DEPS=`echo " $DEPS " | tr -s ' '`
  if grep "^$LINESTART" "$REALSCRIPT" > /dev/null
  then NEW_ENTRY=
  else NEW_ENTRY=true
  fi
  ## Skip adding if dependency is already listed
  if ! echo "$DEPS" | grep "\<$DEP\>" > /dev/null
  then
    ## Was working nicely but abandoned because of whitespacing altering shinanigans:
    # (
      # cat "$REALSCRIPT" |
      # tostring "$FINDLINE"
      # echo "$LINESTART" $DEPS $DEP
      # cat "$REALSCRIPT" |
      # fromstring "$FINDLINE"
    # ) > $NEWSCRIPT
    NEWSCRIPT=/tmp/newscript
    if [ "$NEW_ENTRY" ]
    then
      debug "NEW_ENTRY"
      (
        if head -1 "$REALSCRIPT" | grep "^#!" > /dev/null
        then DROP=1
        else DROP=0
        fi
        cat "$REALSCRIPT" |
        head -$DROP
        echo "$LINESTART$DEPS$DEP"
        cat "$REALSCRIPT" |
        awkdrop $DROP
      ) > $NEWSCRIPT
    else
      cat "$REALSCRIPT" |
      sed "s+^$LINESTART.*+$LINESTART$DEPS$DEP+" |
      cat > $NEWSCRIPT
    fi
    diff "$REALSCRIPT" "$NEWSCRIPT" >&2
    echo -n "`curseyellow`jshdepwiz: Are you happy with the suggested changes to the file? [Yn] `cursenorm`" >&2
    read USER_SAYS
    case "$USER_SAYS" in
      y|Y|"")
        cp "$REALSCRIPT" "$REALSCRIPT.b4jdw" ## backup
        cp $NEWSCRIPT "$REALSCRIPT"
      ;;
    esac
  fi
 }

case "$1" in

  getjshdeps)

    SCRIPT="$2"

    JSH_DEPS=`extractdep -err "$SCRIPT" depends`
    if [ ! "$LAZY" ] && ( [ ! "$?" = 0 ] || [ "$VIGILANT" ] )
    then
      jshdepwiz gendeps "$SCRIPT"
      JSH_DEPS=`extractdep "$SCRIPT" depends`
    fi
    echo "$JSH_DEPS"

  ;;

  getextdeps)

    SCRIPT="$2"

    EXT_DEPS=`extractdep -err "$SCRIPT" ext-depends`
    if [ ! "$LAZY" ] && ( [ ! "$?" = 0 ] || [ "$VIGILANT" ] )
    then
      jshdepwiz gendeps "$SCRIPT"
      EXT_DEPS=`extractdep "$SCRIPT" ext-depends`
    fi
    echo "$EXT_DEPS"

  ;;

  gendeps)

    SCRIPT="$2"
    REALSCRIPT=`getrealscript "$SCRIPT"`

    echo "`cursemagenta`jshdepwiz: Generating dependencies for $SCRIPT`cursenorm`" >&2

    FOUND_JSH_DEPS=`memo findjshdeps "$SCRIPT" | grep " (jsh)$" | takecols 1 | grep -v "^$SCRIPT$" | tr '\n' ' '`
    FOUND_EXT_DEPS=`memo findjshdeps "$SCRIPT" | grep -v " (jsh)$" | grep -v "^  " | takecols 1 | grep -v "^$SCRIPT$" | tr '\n' ' '`
    # replacelinestarting "$SCRIPT" "# jsh-depends:" " $JSH_DEPS"
    # replacelinestarting "$SCRIPT" "# jsh-depends:" " $JSH_DEPS"
    KNOWN_JSH_DEPS=`extractdep "$SCRIPT" depends depends-tocheck depends-ignore`
    KNOWN_EXT_DEPS=`extractdep "$SCRIPT" ext-depends ext-depends-tocheck ext-depends-ignore`
    # CURRENT_TODO_JSH_DEPS=`extractdep "$SCRIPT" depends-tocheck`
    # CURRENT_TODO_EXT_DEPS=`extractdep "$SCRIPT" ext-depends-tocheck`
    # [ "$KNOWN_JSH_DEPS" ] && SORTED_JSH_DEPS=`echo "$KNOWN_JSH_DEPS $CURRENT_TODO_JSH_DEPS" | tr ' ' '\n' | list2regexp` || SORTED_JSH_DEPS="^$"
    [ "$KNOWN_JSH_DEPS" ] && SORTED_JSH_DEPS=`echo "$KNOWN_JSH_DEPS" | tr ' ' '\n' | trimempty | list2regexp` || SORTED_JSH_DEPS="^$"
    [ "$KNOWN_EXT_DEPS" ] && SORTED_EXT_DEPS=`echo "$KNOWN_EXT_DEPS" | tr ' ' '\n' | trimempty | list2regexp` || SORTED_EXT_DEPS="^$"
    # echo "Echoing: $FOUND_JSH_DEPS   Ungrepping: $SORTED_JSH_DEPS" >&2
    NEW_JSH_DEPS=`echo "$FOUND_JSH_DEPS" | tr ' ' '\n' | grep -v "$SORTED_JSH_DEPS"`
    NEW_EXT_DEPS=`echo "$FOUND_EXT_DEPS" | tr ' ' '\n' | grep -v "$SORTED_EXT_DEPS"`
    # echo "# jsh-depends-tocheck: + $NEW_JSH_DEPS" >&2
    # echo "# jsh-ext-depends-tocheck: + $NEW_EXT_DEPS" >&2
    # [ "$NEW_JSH_DEPS" = "" ] && echo "`cursemagenta`jshdepwiz: No new dependencies found in $SCRIPT`cursenorm`" >&2
    if [ "$NEW_JSH_DEPS" = "" ]
    then
      adddeptoscript "$REALSCRIPT" depends ""
    fi
    for DEP in $NEW_JSH_DEPS
    do
      if [ "$INTERACTIVE" ]
      then
        echo "`curseyellow`jshdepwiz: Calls to `cursered;cursebold`$DEP`curseyellow` are made in `cursecyan`$SCRIPT`curseyellow`:`cursenorm`" >&2
        higrep "\<$DEP\>" -C1 "$REALSCRIPT" | sed 's+^+  +' >&2
        echo -n "`curseyellow`jshdepwiz: Do you think this is a real dependency? [Yn] `cursenorm`" >&2
        read USER_SAYS
        case "$USER_SAYS" in
          n|N)
            adddeptoscript "$REALSCRIPT" depends-ignore "$DEP"
          ;;
          *)
            adddeptoscript "$REALSCRIPT" depends "$DEP"
          ;;
        esac
        echo >&2
      else
        echo addtoline ... >&2
      fi
    done
    ## TODO: EXT

  ;;

  *)

    echo "jshdepwiz: command \"$*\" not recognised."
    exit 1

  ;;

esac
