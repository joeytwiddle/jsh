#!/bin/sh
# Present output like `ls -l`, but annotate each file with its git status.

# BUG: When directories are passed as arguments, they are not listed the same as with ls.  Instead of just filenames, each files full path is displayed.
# Note that git is (currently) run from the caller's working directory, so cannot inspect files from a different repository.

find "$@" -maxdepth 1 |
#find "$@" -type f | grep -v "/\.git/" |
sed 's+^\./++' |
if which sortfilesbydate >/dev/null
then sortfilesbydate
else cat
fi |
while read node
do
	cwd="$PWD"
	lnode="$(basename "$node")"
	cd "$(dirname "$node")"
	# Fallback (default) status.  Not many things get this.  Broken symlinks do (untracked, not sure about tracked).
	extra="--"
	if [ -d "$lnode" ]
	then
		# Recursive mode is optional because it's a lot slower on large repositories.
		if [ -n "$GITLS_CHECK_FOLDERS" ]
		then
			# If any file below is modified, display that
			modified=$(git status --porcelain "$lnode" 2>/dev/null | grep -m 1 -o "^.M")
			if [ -n "$modified" ]
			then extra="$modified"
			else
				# If any file below is unknown, then display that
				unknown=$(git status --porcelain "$lnode" 2>/dev/null | grep -m 1 -o "^??")
				if [ -n "$unknown" ]
				then extra="$unknown"
				else
					# Just display the first thing that git reports
					whatever=$(git status --porcelain "$lnode" 2>/dev/null | grep -m 1 -o "^..")
					if [ -n "$whatever" ]
					then extra="$whatever"
					else extra="  "
					fi
				fi
			fi
		else
			# A directory with unknown contents
			extra="::"
			#extra=".."
			#extra="##"
			#extra="  "
		fi
	elif [ -f "$lnode" ]
	then
		# Get the two-character status that git reports for this file
		# We look for ignored files, they sometimes produce "!!" but occasionally ""
		# Up-to-date files always produce ""
		# Unfortunately, if we are not in a git folder, then we also get ""!
		extra="$(git status --porcelain --ignored "$lnode" 2>/dev/null | cut -c 1-2)"
		[ "$extra" = "" ] && extra="  "
	fi
	#echo -n "$extra "
	cd "$cwd"
	ls -ld --color "$node" | sed "s+^\([^ ]* *\)\{8\}+\0[$extra] +"
done |
if which columnise-clever >/dev/null
then
	columnise-clever -ignore '^[^ ]* *[^ ]* *[^ ]* *[^ ]* *[^ ]* *[^ ]* *[^ ]* *[^ ]*[^ ]* *[^ ]*' |
	# columnise-clever left-aligns fields, but we want the 5th field (file size) right-aligned
	sed 's+^\(\([^ ]* *\)\{4\}\)\([^ ]*\)\( *\) +\1\4\3 +'
else cat
fi
