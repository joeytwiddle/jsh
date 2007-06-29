## jsh-help: given a string, toregexp returns a regular expression that should match only that string (i.e. all special regexp chars are appropriately escaped)
## jsh-help: Single use: toregexp <string>
## jsh-help: Stream use: cat <data> | toregexp

## TODO: not yet tested; do some huge sets of tests...

if [ "$#" = 0 ]
then cat
else printf "%s" "$*"
fi |

sed '
	s+\\+\\\\+g
	## These work for remake_cachedir_links:
	s+\[+\\\[+g
	s+\]+\\\]+g
	## But these work for: ut_finddeps /mnt/data/ut_server/restored_from_cache/CTF-Revenge-LE102.unr
	# s+\[+\\\\\[+g
	# s+\]+\\\\\]+g
	s+\^+\\^+g
	s+\$+\\$+g
	s+\.+\\.+g
	s+\*+\\*+g
'
