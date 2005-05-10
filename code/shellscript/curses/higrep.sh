#!/bin/sh

## Recommended usage:
## higrep <grepstring> [ <grepopts> ... ] [ <grepfiles> ... ]
## -E to grep will not be passed to sed, but sed does regex (although there are some differences)

# jsh-ext-depends: sed
# jsh-depends: curseblue highlight cursenorm countargs cursebold cursecyan

if [ ! "$*" ] || [ "$1" = --help ]
then cat << !

higrep <regexp> [ <grep_options> ]* [ <files> ]*

  Like grep, but highlights occurrences of the regexp in a random colour.

  Note: highlight uses sed so your <regexp> should be grep and sed compatible.

  If multiple arguments are given, it also attempts highlighting of filenames
  in a multi-file search, and context regions in a context grep.

!
exit 1
fi

## The stderr pipe is not vital, but grep * often give annoying directory errors which I want to ignore.  TODO: isn't there is an option to ignore just them so we can keep other errors?  DONE
# grep --line-buffered "$@" 2>/dev/null |
grep --line-buffered -d skip "$@" |

## Special highlighting for multiple-file and context greps,
## but it can false-positive, so we don't do it if there is only one arg.
## You might want to disable this if you find them Too annoying, or we could try to firmly establish whether multiple file input or -r, and only enable them then...
if [ "$2" ] && [ ! "$HIGREP_NO_CONTEXT" ]
then

	## Um I'm not sure what this one is for:
	sed -u "s|^--$|`curseblue`--`cursenorm`|" | ## And I don't know why it doesn't prevent later ^ regexps from failing!

	## Render lines beginning <filename>: or <filename>-
	## BUG (nasty): highlighting match can end too early if the actual filename matches the seach expr!
	## Highlight filenames (up to ':'):
	sed -u "s|^\([^:-]*\)\(:\)|`cursecyan;cursebold`\1\2`cursenorm`$TABCHAR|" |
	## Highlight -A -B or -C filenames (up to '-'):  KNOWN (UNFIXABLE) BUG: higlight stops early if filename contains '-'!
	sed -u "s|^\([^:-]*\)\(-\)|`cursecyan`\1\2`cursenorm`$TABCHAR|" |

	cat

else

	cat

fi |

## Finally we will highlight the expression you wanted:
highlight "$1"
