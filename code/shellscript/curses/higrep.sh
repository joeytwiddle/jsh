#!/bin/sh
# Recommended usage:
# higrep <grepstring> [ <grepopts> ... ] [ <grepfiles> ... ]
# -E to grep will not be passed to sed, but sed does regex (although there are some differences)

if test "$*" = ""; then
	echo "higrep <search_expr> [ <grep_options> ] [ <files> ]"
	echo "  Like normal grep, but highlights the located string (and files if shown)."
	echo "  Note: highlight uses sed so <search_expr> should be grep and sed compatible."
	exit 1
fi

# The stderr pipe is optional, but grep * always give annoying directory errors
grep $GREPARGS "$@" 2>/dev/null |
	# This if is meant to render cyan up to ':' only if searching multiple files, but does not check for -c mode etc.
	# also catch '-' for context grep
	if test `countargs "$@"` -gt 1; then
		sed "s|^--$|`curseblue`--`cursenorm`|" | ## Don't understand why this one doesn't prevent later ^ regexps from failing!
		sed "s|^\([^:-]*\)\(:\)|`cursecyan;cursebold`\1\2`cursenorm`$TABCHAR|" |
		sed "s|^\([^:-]*\)\(-\)|`cursecyan`\1\2`cursenorm`$TABCHAR|" |
		cat
	else
		cat
	fi |
	highlight "$1"
