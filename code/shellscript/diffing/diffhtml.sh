OLDFILE="$1"
NEWFILE="$2"

quicktidy () {
	sed 's+><+>\
<+g'
}

cat "$OLDFILE" | quicktidy > "$OLDFILE".tidy
cat "$NEWFILE" | quicktidy > "$NEWFILE".tidy

OLDFILE="$OLDFILE".tidy
NEWFILE="$NEWFILE".tidy

PATCHFILE=`jgettmp diffhtml_patch`

diff -C3 "$OLDFILE" "$NEWFILE" |

sed 's|^+ \(.*\)$|+ <div class="added">\1</div>|' |
# sed 's|^- \(.*\)$|\! <div class="added">\1</div>|' |

cat > "$PATCHFILE"

cp "$OLDFILE" tmp.html

patch tmp.html < "$PATCHFILE"

cat tmp.html |
sed 's+<[Hh][Ee][Aa][Dd]>+<head><link rel="stylesheet" type="text/css" href="http://hwi.ath.cx/tmp/diffstyles.css" media="all">+' |
pipebackto tmp.html

echo "jdeltmp \"$PATCHFILE\""

echo "tmp.html created"
