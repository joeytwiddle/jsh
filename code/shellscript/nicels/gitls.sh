# BUG: When directories are passed as arguments, they are not listed the same as with ls.
find "$@" -maxdepth 1 |
#find "$@" -type f | grep -v "/\.git/" |
sed 's+^\./++' |
sortfilesbydate |
while read node
do
	extra="--"
	if [ -d "$node" ]
	then
		if [ -n "$GITLS_CHECK_FOLDERS" ]
		then
			modified=$(git status --porcelain "$node" 2>/dev/null | grep -m 1 -o "^.M")
			if [ -n "$modified" ]
			then extra="$modified"
			else
				unknown=$(git status --porcelain "$node" 2>/dev/null | grep -m 1 -o "^??")
				if [ -n "$unknown" ]
				then extra="$unknown"
				else extra="  "
				fi
			fi
		else
			extra="::"
		fi
	elif [ -f "$node" ]
	then
		extra="$(git status --porcelain --ignored "$node" 2>/dev/null | cut -c 1-2)"
		[ "$extra" = "" ] && extra="  "
	fi
	#echo -n "$extra "
	ls -ld --color "$node" | sed "s+^\([^ ]* *\)\{8\}+\0[$extra] +"
done |
columnise-clever -ignore '^[^ ]* *[^ ]* *[^ ]* *[^ ]* *[^ ]* *[^ ]* *[^ ]* *[^ ]*[^ ]* *[^ ]*'
