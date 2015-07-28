find "$@" -maxdepth 1 |
#find "$@" -type f | grep -v "/\.git/" |
sed 's+^\./++' |
sortfilesbydate |
while read node
do
	extra="--"
	if [ -d "$node" ]
	then extra="  "
	elif [ -f "$node" ]
	then
		extra="$(git status --porcelain --ignored "$node" 2>/dev/null | cut -c 1-2)"
		[ "$extra" = "" ] && extra="  "
	fi
	#echo -n "$extra "
	ls -ld --color "$node" | sed "s+^\([^ ]* *\)\{8\}+\0[$extra] +"
done |
columnise-clever -ignore '^[^ ]* *[^ ]* *[^ ]* *[^ ]* *[^ ]* *[^ ]* *[^ ]* *[^ ]*[^ ]* *[^ ]*'
