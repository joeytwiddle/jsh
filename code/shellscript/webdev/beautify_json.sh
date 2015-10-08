cat "$@" |
python -m json.tool |
sed 's+ $++'

# See also: prettycat (jsh)

# One disadvantage: it sorts the keys, rather than keeping them in the original order
