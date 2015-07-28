find "$@" -maxdepth 1 |
sortfilesbydate |
while read node
do
	extra="[DD]"
	if [ -f "$node" ]
	then extra="[$(git status --porcelain "$node" | cut -c 1-2)]"
	fi
	ls -ld --color "$node" | sed "s+^\([^ ]* *\)\{8\}+\0$extra +"
done
