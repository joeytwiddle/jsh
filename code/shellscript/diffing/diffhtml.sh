## To display the diff, some style definitions must be made
## either by linking to a remote file:
# ADDTOHEAD='<link rel="stylesheet" type="text/css" href="http://hwi.ath.cx/tmp/diffstyles.css" media="all">'
## Or by direct inclusion in the page, which makes it standalone.
ADDTOHEAD='<STYLE type="text/css">'`
	cat /var/www/tmp/diffstyles.css |
	sed 's+$+\\\\+'
`'</STYLE>'

OLDFILE="$1"
NEWFILE="$2"

quicktidy () {
	sed 's+><+>\
<+g'
}

cat "$OLDFILE" | quicktidy > "$OLDFILE".tidy
cat "$NEWFILE" | quicktidy > "$NEWFILE".tidy

## IMPORTANT: if you change these two lines, you should also change the "del" below...
OLDFILE="$OLDFILE".tidy
NEWFILE="$NEWFILE".tidy

PATCHFILE=`jgettmp diffhtml_patch`

diff -U3 "$OLDFILE" "$NEWFILE" |
sed 's|^+\(.*\)$|+<div class="added">\1</div>|' |
## This one causes problems, eg. with Bristol Indymedia:
# sed 's|^! \(<span class="date">03/02 11:55.*\)$|! <div class="changed">\1</div>|' |
# sed 's|^- \(.*\)$|\! <div class="added">\1</div>|' |

cat > "$PATCHFILE"

# editandwait "$PATCHFILE"

cp "$OLDFILE" tmp.html

patch tmp.html < "$PATCHFILE"

cat tmp.html |
sed "s+<[Hh][Ee][Aa][Dd]>+<head>$ADDTOHEAD+" |
pipebackto tmp.html

## Doesn't work:  better to just reverse what we've already done
# diff -U3 "$OLDFILE" "$NEWFILE" |
# sed 's|^-\(.*\)$|-<div class="removed">\1</div>|' |
# cat > "$PATCHFILE"
# cp "$OLDFILE" tmp.old.html
# patch tmp.old.html < "$PATCHFILE"

jdeltmp \"$PATCHFILE\"
del "$OLDFILE" "$NEWFILE"

echo "tmp.html created"
