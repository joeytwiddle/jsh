## Get a script's dependencies

## Get a script's dependency data
## Generate a script's dependency data
## Compare and add new dependencies to tocheck list

## If a script needs dependencies checking, invoke the wizard.

## Suggested protocol:

# jsh-depends: <jsh_scripts>
# jsh-ext-depends: <real_progs>
# jsh-depends-ignore: 
# jsh-depends-tocheck: 

## Note: instead of commenting out, the first two could be sourced and checked at runtime.

function getrealscript () {
  jwhich inj "$1"
}

function extractdep () {
  SCRIPT="$1"
  REALSCRIPT=`getrealscript "$1"`
  LINE="$2"
  RES=`
    cat "$REALSCRIPT" |
    grep "^# jsh-$LINE:"
  `
  [ ! "$?" = 0 ] && return 1
  echo "$RES" |
  sed 's+^# jsh-$LINE:++'
}

case "$1" in

  getjshdeps)

    SCRIPT="$2"

    JSH_DEPS=`extractdep "$SCRIPT" depends`
    if [ ! "$?" = 0 ]
    then
      jshdepwiz gendeps "$SCRIPT"
      JSH_DEPS=`extractdep "$SCRIPT" depends`
    fi
    echo "$JSH_DEPS"

  ;;

  getextdeps)

    SCRIPT="$2"

    EXT_DEPS=`extractdep "$SCRIPT" ext-depends`
    if [ ! "$?" = 0 ]
    then
      jshdepwiz gendeps "$SCRIPT"
      EXT_DEPS=`extractdep "$SCRIPT" ext-depends`
    fi
    echo "$EXT_DEPS"

  ;;

  gendeps)

    SCRIPT="$2"

    echo "`curseyellow`Generating dependencies for $SCRIPT`cursenorm`" >&2

    FOUND_JSH_DEPS=`findjshdeps "$SCRIPT" | grep " (jsh)$" | takecols 1 | tr '\n' ' '`
    FOUND_EXT_DEPS=`findjshdeps "$SCRIPT" | grep -v " (jsh)$" | grep -v "^  " | trimempty | takecols 1 | tr '\n' ' '`
    # replacelinestarting "$SCRIPT" "# jsh-depends:" " $JSH_DEPS"
    # replacelinestarting "$SCRIPT" "# jsh-depends:" " $JSH_DEPS"
    CURRENT_JSH_DEPS=`extractdep "$SCRIPT" depends`
    CURRENT_EXT_DEPS=`extractdep "$SCRIPT" ext-depends`
    [ "$CURRENT_JSH_DEPS" ] && SORTED_JSH_DEPS=`echo "$CURRENT_JSH_DEPS" | tr ' ' '\n' | list2regexp` || SORTED_JSH_DEPS="^$"
    [ "$CURRENT_EXT_DEPS" ] && SORTED_EXT_DEPS=`echo "$CURRENT_EXT_DEPS" | tr ' ' '\n' | list2regexp` || SORTED_EXT_DEPS="^$"
    NEW_JSH_DEPS=`echo "$FOUND_JSH_DEPS" | grep -v "$SORTED_JSH_DEPS"`
    NEW_EXT_DEPS=`echo "$FOUND_EXT_DEPS" | grep -v "$SORTED_EXT_DEPS"`
    echo "# jsh-depends-tocheck: + $NEW_JSH_DEPS"
    echo "# jsh-ext-depends-tocheck: + $NEW_EXT_DEPS"

  ;;

  *)

    echo "jshdepwiz: command \"$*\" not recognised."
    exit 1

  ;;

esac
