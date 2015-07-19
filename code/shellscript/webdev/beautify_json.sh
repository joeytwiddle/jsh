cat "$@" |
python -m json.tool |
sed 's+ $++'

# One disadvantage: it sorts the keys, rather than keeping them in the original order
