cat "$@" |
python -m json.tool |
sed 's+ $++'

# See also: prettycat (jsh)

# See also: js-beautify (npm) which also provides css-beautify and html-beautify

# One disadvantage: it sorts the keys, rather than keeping them in the original order
