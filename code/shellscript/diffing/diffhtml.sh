## To display the diff, some style definitions must be made
## either by linking to a remote file:
# ADDTOHEAD='<link rel="stylesheet" type="text/css" href="http://hwi.ath.cx/tmp/diffstyles.css" media="all">'
## Or by direct inclusion in the page, which makes it standalone.
ADDTOHEAD='<STYLE type="text/css">'`
	( cat /var/www/tmp/diffstyles.css || wget -O - "http://hwi.ath.cx/tmp/diffstyles.css" ) |
	sed 's+$+\\\\+'
`'</STYLE>'

OLDFILE="$1"
NEWFILE="$2"

quicktidy () {
	sed 's+><+>\
<+g'
}

## Used to use w3c tidy, but it didn't really do what was needed (or was it just too slow?)
cat "$OLDFILE" | quicktidy > "$OLDFILE".tidy
cat "$NEWFILE" | quicktidy > "$NEWFILE".tidy

## IMPORTANT: if you change these two lines, you should also change the "del" below...
OLDFILE="$OLDFILE".tidy
NEWFILE="$NEWFILE".tidy

PATCHEDFILE=`jgettmp diffhtml_diffed`

cp "$OLDFILE" "$PATCHEDFILE"

diff -U3 "$OLDFILE" "$NEWFILE" |
# sed 's|^+\(.*\)$|+<div class="added">\1</div>|' |
sed 's|^+\([^+].*\)$|+<div class="added">\1</div>|' |
## This one causes problems, eg. with Bristol Indymedia:
# sed 's|^! \(<span class="date">03/02 11:55.*\)$|! <div class="changed">\1</div>|' |
# sed 's|^- \(.*\)$|\! <div class="added">\1</div>|' |
patch "$PATCHEDFILE" |

# ## Nasty nasty hack to drop the error message
# grep -v "^missing header for unified diff at line" |
## OK but the error only appears because we change the initial +++ line.
## Oh dear this one is still needed!
grep -v "^patching file $PATCHEDFILE$"

cat "$PATCHEDFILE" |
sed "s+<[Hh][Ee][Aa][Dd]>+<head>$ADDTOHEAD+"

jdeltmp "$PATCHEDFILE"
# del "$OLDFILE" "$NEWFILE"
