#!/bin/sh

# jsh-depends: curseblue highlight cursenorm countargs

## Recommended usage:
## higrep <grepstring> [ <grepopts> ... ] [ <grepfiles> ... ]
## -E to grep will not be passed to sed, but sed does regex (although there are some differences)

if [ ! "$*" ]
then
	echo
	echo "higrep <regexp> [ <grep_options> ]* [ <files> ]*"
	echo
	echo "  Like normal grep, but highlights occurrences of the regexp in a random colour."
	echo
	echo "  Note: highlight uses sed so your <regexp> should be grep and sed compatible."
	echo
	exit 1
fi

## The stderr pipe is optional, but grep * always give annoying directory errors
grep $GREPARGS "$@" 2>/dev/null |
	## This if is meant to render cyan up to ':' only if searching multiple files, but does not check for -c mode etc.
	## also catch '-' for context grep
	if test `countargs "$@"` -gt 1; then

		## Um I'm not sure what this one is for:
		sed "s|^--$|`curseblue`--`cursenorm`|" | ## Don't understand why this one doesn't prevent later ^ regexps from failing!

    ## Render lines beginning <filename>: and <filename>-
    ## You might want to disable these if you find them Too annoying, or we could try to establish multiple file input or -r, and only enable them then...
		## Highlight filenames (up to ':'):  KNOWN (UNFIXABLE) BUG: can be interrupted if filename matches seach expr
		sed "s|^\([^:-]*\)\(:\)|`cursecyan;cursebold`\1\2`cursenorm`$TABCHAR|" |
		## Highlight -A -B or -C filenames (up to '-'):  KNOWN (UNFIXABLE) BUG: higlight stops early if filename contains '-'!
		sed "s|^\([^:-]*\)\(-\)|`cursecyan`\1\2`cursenorm`$TABCHAR|" |

		cat
	else
		cat
	fi |
	highlight "$1"
