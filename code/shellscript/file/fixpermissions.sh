## Default behaviour with no arguments:

. importshfn foreachdo

fix_dirs() {
	chmod ugo+rx "$@"
	chmod ug+w "$@"
	chmod o-w "$@"
}

fix_files() {
	chmod ugo+r "$@"
	chmod ug+w "$@"
	chmod o-w "$@"
}

listFile=/tmp/list_before.fix_permissions.$$.joey
'ls' -lR > "$listFile"

find . -type d |
foreachdo fix_dirs

find . -type f |
foreachdo fix_files

'ls' -lR > "$listFile.new"

if diff "$listFile" "$listFile".new | grep .
then echo "Changes! $listFile -> $listFile.new"
else echo "No changes." ; 'rm' -f "$listFile" "$listFile.new"
fi

