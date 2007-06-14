
### TESTING NEW

printf "%s" "$*" | wc -m
exit



### Original:

# jsh-depends: countlines
# if test ! "$1" = ""; then
echo "$@" |
# else
	# cat
# fi |
tr -d "\n" |
sed 's/./\
/g' |
countlines

