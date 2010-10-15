#!/bin/sh
## Given a string, returns a regular expression that would match that string, ignoring case.
## No longer drops trailing non-alphas; but I still don't understand it and haven't fully tested it.
## Might not work as desired on escaped chars.


echo "$@" |

sed '
	y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/
	s/[a-z]/[&]/g
	/^$/!s/$/AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz/
	:a
	s/\[\([a-z]\)\]\(.*\)\(.\)\1/[\3\1]\2\3\1/
	ta
	s/AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz$//
'
