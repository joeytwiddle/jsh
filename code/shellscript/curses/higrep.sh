#!/bin/sh
# jsh-depends-ignore: arguments

# We can achieve something similar with ripgrep. Unfortunately grep uses BRE
# (Basic Regular Expressions) but ripgrep does not support BRE.
#if command -v rg >/dev/null 2>&1
#then
#      rg --no-heading --no-line-number "$@"
#      exit
#fi

## See also: Modern grep has --colour=auto, which only invokes when the output
## is to terminal(tty/pts) (not piped).
##
## This might make higrep redundant.  However I am still using it on those
## occasions when the output IS piped but I still want it highlighted.  So
## let's never fix that 'not checking tty bug' in higrep.  ;)

## BUG TODO: Exit code does not perform like grep

## TODO: Should process -i and set highlight correctly (maybe using caseinsensitiveregexp)

## Recommended usage:
## higrep <grepstring> [ <grepopts> ... ] [ <grepfiles> ... ]
## -E to grep will not be passed to sed, but sed does regex (although there are some differences)

# jsh-ext-depends: sed
# jsh-depends: curseblue highlight cursenorm countargs cursebold cursecyan

## DONE: Detect if we are outputting to pts or to another pipe, and decide
## whether to add highlight colors or not.
# if isatty
# then doHighlight=1
# else doHighlight=""
# fi
## Sod that.  higrep is explicit, and I want to use it with 'more'!
doHighlight=1


if [ ! "$*" ] || [ "$1" = --help ]
then cat << !

higrep <regexp> [ <grep_options> ]* [ <files> ]*

  Like grep, but highlights occurrences of the regexp in a random colour.

  Note: highlight uses sed so your <regexp> should be grep and sed compatible.

  If multiple arguments are given, it also attempts highlighting of filenames
  in a multi-file search, and context regions in a context grep.

  BUG TODO: higrep does not always return the correct exit value (=grep's).
        Can this simply be solved with a "grep ." at the end of the |s?

!
exit 1
fi

## The stderr pipe is not vital, but grep * often give annoying directory errors which I want to ignore.  TODO: isn't there is an option to ignore just them so we can keep other errors?  DONE
# grep --line-buffered "$@" 2>/dev/null |
# grep --line-buffered -d skip "$@" |
## Since we are outputting coloured text, output coloured errors too:
highlightstderr grep --line-buffered -d skip "$@" |

if [ "$doHighlight" ]
then

	## Special highlighting for multiple-file and context greps,
	## but it can false-positive, so we don't do it if there is only one arg.
	## You might want to disable this if you find them Too annoying, or we could try to firmly establish whether multiple file input or -r, and only enable them then...
	if [ "$2" ] && [ ! "$HIGREP_NO_CONTEXT" ]
	then

		## Color the marker lines in context greps, that say we skipped some lines
		sed -u "s|^--$|`curseblue`--`cursenorm`|" | ## And I don't know why it doesn't prevent later ^ regexps from failing!

		## Render lines beginning <filename>: or <filename>-
		## BUG (nasty): highlighting match can end too early if the actual filename matches the seach expr!
		## Highlight filenames (up to ':'):
		sed -u "s|^\([^:-]*\)\(:\)|`cursecyan;cursebold`\1\2`cursenorm`$TABCHAR|" |
		## Highlight -A -B or -C filenames (up to '-'):  KNOWN (UNFIXABLE) BUG: higlight stops early if filename contains '-'!
		# sed -u "s|^\([^:-]*\)\(-\)|`cursecyan`\1\2`cursenorm`$TABCHAR|" |
		## If no filenames were generated, the - may be matched in the text; breaking proper highlighting matches; this avoids line starting with whitespace; but really we should determine whether filenames are expected or not:
		sed -u "s|^\([^ 	][^:-]*\)\(-\)|`cursecyan`\1\2`cursenorm`$TABCHAR|" |

		cat

	else

		cat

	fi |

	## Finally we will highlight the expression you wanted:
	highlight "$1"

else cat
fi

