df -h |
if test "$1" = ""; then
	cat
else
	higrep "$1"
fi
