## all vimscripts have the same version management system and can be acquired generically
## all sourceforge packages have a similar query interface but different versioning + installs
## if we are to cover specific popular services (as above) as well as the generic "i dunno" case, we should allow for these

## CONSIDER:
## - What if they don't provide CVS or zipped upped packages, but just an FTP source tree?
## - Should the web method try to get a page with all versions or a page witha regexp to the latest version?

## TODO: When seen in the update method, in fact the creation of a new package config only
## requires that the user create the above variables.
## They can do this interactively if the config script helps them choose
## the correct commands, and keep re-trying the method (and cleaning up)
## until it works as needed.
## (By letting the user form the commands they have complete control if
## there is a complicated situation.)
## This retrial wizard is repeated functionality, which should be abstracted
## out in the code below.

## TODO: make hakpak more wizardy and clever

## But anyway the update method is almost the new method (just an extra check needs update bit)
## So really update should be a non-interactive version of new.
## That way when bits fail, it can be run in partially-interactive mode, so developer can fix the relevant command.
## It may be just a special case of the buildcommand function.

## How is hakpak different from any other situation where you need to build up and test a set of commands?
## Not much, it just suggests approriate things to do!

if [ "$1" = "" ] || [ "$1" = --help ]
then cat << !

hakpak manages updates for software which is not yet packaged for your distro.

Usage:

  hakpak list [<pattern>] : lists all available hakpak managed packages
  hakpak new <name>       : interactive create a new hakpak package
  hakpak update <name>    : attempt to update to the latest version

In future hakpak may support building of rpm's .deb's etc.

Note: hakpak is very experimental.

!
exit 1
fi

function buildcommand () {

  COMNAME="$1"
  MEANING="$2"
  SUGGESTED="$3"

  echo "We now need a command to $MEANING"

  while true
  do
    echo "Current suggestion is:"
    echo "$SUGGESTED"
    echo "What do you want to try next?"
    read SUGGESTED
    echo "Running: $SUGGESTED"
    echo "::::::::::::::::::::::::::::::::::::::::::::::"
    eval "$SUGGESTED"
    echo "::::::::::::::::::::::::::::::::::::::::::::::"
    echo "Did that command successfully complete the task? [yN]"
    read DONE
    case "$DONE" in
      y|Y)
        break
      ;;
    esac
  done

  echo "OK, $COMNAME=$SUGGESTED"
  eval "$COMNAME=\"$SUGGESTED\""

}

case "$1" in

  list)
    echo "hakpak: Not yet implemented: $1"
    exit 2
  ;;

  update)
    echo "hakpak: Not yet implemented: $1"
    exit 2

    NAME="$2"
    CONFFILE="$JPATH/data/hakpak/$NAME.conf"
    if [ ! -f "$CONFFILE" ]
    then
      echo "hakpak: No config file $CONFFILE found for $NAME."
      exit 1
    fi
    source "$CONFFILE"

    eval "$GET_VERSION_LISTINGS"
    eval "$EXTRACT_VERSION_LISTINGS"
    eval "$FIND_LATEST_VERSION"
    ## check if need updating
    eval "$GET_UPDATE"
    eval "$UNZIP_IF_NEEDED"
    eval "$COMPILE_PACKAGE"
    eval "$INSTALL_PACKAGE"
    ## if all well, update present version in db, otherwise cleanup / report error

  ;;

  new)

    if which ledit > /dev/null 2>&1 && [ ! "$2" = -ledited ]
    then
      ledit hakpak new -ledited "$@"
      exit
    fi
    [ "$2" = -ledited ] && shift
    shift

    NAME="$2"

    echo "Are we getting the package from CVS or from the WWW/FTP? [CW]"
    while read METHOD
    do
      case "$METHOD" in
        C|c)
          METHOD=cvs; break
        ;;
        W|w|F|f)
          METHOD=web; break
        ;;
        *)
          echo "Choose <C> or <W>."
        ;;
      esac
    done

    case $METHOD in

      cvs)
        echo "hakpak: Not yet implemented: CVS"
        exit 2
      ;;

      web)

        echo "OK first you'll have to tell me the URL (web-address) where I can find a zip/tar of the package."
        echo "Or press one of the following for a search on \"$NAME\":"
        echo "  <G>oogle"
        echo "  Google feeling <L>ucky"
        echo "  <F>reshmeat"
        echo "  <S>ourceforge"
        ## TODO: Consider moving these searches to a constant variable or a dependent file."

        while read URL
        do
          case "$URL" in
            G|g)
              browse `googlesearch "$NAME"` &
            ;;
            L|l)
              browse `googlesearch -lucky "$NAME"` &
            ;;
            F|f)
              browse `freshmeatsearch "$NAME"` &
            ;;
            S|s)
              browse `sourceforgesearch "$NAME"` &
            ;;
            http://*)
              break
            ;;
            ftp://*)
              break
            ;;
            *)
              echo "That isn't a URL or a search command"
            ;;
          esac
        done

        PAGE=`jgettmp "hakpak-page-$NAME.html"`
        wget "$URL" -O "$PAGE"

        echo "OK so now we need to extract the different versions available on the page."
        echo "TODO: or just find the link if this page displays only the most up-to-date version."

        ## TODO...
        # EXTRACT_VERSION_LISTINGS=`buildcommand "produce a list of all the zip (or otherwise packaged) files on the page." "cat \'$PAGE\' | extractregex \'\\\"$NAME\.*zip\\\"\'"`
        ## Look for bzip2 / tar.gz / tgz / zip / jar / ...
        ## Offer case insensitive search
        buildcommand EXTRACT_VERSION_LISTINGS "produce a list of all the zip (or otherwise packaged) files on the page." "cat \"$PAGE\" | extractregex \"\\\"$NAME\.*zip\\\"\""
        echo "Got: $EXTRACT_VERSION_LISTINGS"

        ## Establish whether or how they need sorting, and take the most recent version from the bottom (or top).

      ;;

    esac

  ;;

  *)
    echo "hakpak: command not recognised: $1 ($*)"
    exit 1
  ;;

esac
