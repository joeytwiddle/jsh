#!/bin/sh
# Present output like `ls -l`, but annotate each file with its git status.

# BUG: When directories are passed as arguments, they are not listed the same as with ls.  Instead of just filenames, each file's full path is displayed.

if [ "$1" = -l ]
then GITLS_LONG_FORMAT=1; shift
fi

if [ "$1" = -R ]
then GITLS_CHECK_FOLDERS=1; shift
fi

# Run `git status` a single time and cache the result, instead of forking git
# once per listed file.  Clean files will not be listed in the cache.
git_root="$(git rev-parse --show-toplevel 2>/dev/null)"
if [ -n "$git_root" ]
then git_status_cache="$(git status --porcelain --ignored 2>/dev/null)"
else git_status_cache=""
fi

# Porcelain paths are root-relative, but the listed paths are relative to $PWD,
# so we need the path from the repo root down to $PWD (empty when at the root).
case "$PWD" in
	"$git_root") cwd_prefix="" ;;
	*) cwd_prefix="${PWD#"$git_root"/}/" ;;
esac

# Echo a listed path the way git reports it (relative to the repo root).
rootrel() {
	case "$1" in
		/*) printf '%s' "${1#"$git_root"/}" ;;
		*) printf '%s' "$cwd_prefix$1" ;;
	esac
}

find "$@" -maxdepth 1 |
#find "$@" -type f | grep -v "/\.git/" |
sed 's+^\./++' |
if which sortfilesbydate >/dev/null 2>&1
then sortfilesbydate
else cat
fi |
while read node
do
	# Fallback (default) status.  Not many things get this.  Untracked broken symlinks do (not sure about tracked), and sockets do.
	# According to logic below, these are things which are not directories and not files.
	extra="xx"
	if [ -d "$node" ]
	then
		# Recursive mode is optional because it's a lot slower on large repositories.
		if [ -n "$GITLS_CHECK_FOLDERS" ]
		then
			# All cached lines for files below this directory.
			status_line="$(printf '%s\n' "$git_status_cache" | awk -v d="$(rootrel "$node")/" 'substr($0, 4, length(d)) == d')"
			# If any file below is modified, display that
			modified=$(printf "%s" "$status_line" | grep -m 1 -o "^.M")
			if [ -n "$modified" ]
			then extra="$modified"
			else
				# If any file below is unknown, then display that
				unknown=$(printf "%s" "$status_line" | grep -m 1 -o "^??")
				if [ -n "$unknown" ]
				then extra="$unknown"
				else
					# Just display the first thing that git reports
					whatever=$(printf "%s" "$status_line" | grep -m 1 -o "^..")
					if [ -n "$whatever" ]
					then extra="$whatever"
					else extra="  "
					fi
				fi
			fi
		else
			# A directory with unknown contents
			extra="--"
			#extra="::"
			#extra=".."
			#extra="##"
			#extra="  "
		fi
	elif [ -f "$node" ]
	then
		# Look this file up in the cached status.  An absent entry means the
		# file is clean (or we are not in a git repo), giving a blank status.
		status_line="$(printf '%s\n' "$git_status_cache" | awk -v p="$(rootrel "$node")" 'substr($0, 4) == p { print; exit }')"
		if [ -n "$status_line" ]
		then extra="$(printf "%s" "$status_line" | cut -c 1-2)"
		else extra="  "
		fi
	fi
	#echo -n "$extra "
	if [ -n "$GITLS_LONG_FORMAT" ]
	then ls -ld --color "$node" | sed "s+^\([^ ]* *\)\{8\}+\0[$extra] +"
	else ls -d --color "$node" | sed "s+^+[$extra] +"
	fi
done |
if [ -n "$GITLS_LONG_FORMAT" ] && which columnise-clever >/dev/null 2>&1
then
	# Ubuntu
	#columnise-clever -ignore '^[^ ]* *[^ ]* *[^ ]* *[^ ]* *[^ ]* *[^ ]* *[^ ]* *[^ ]* *[^ ]*' |
	# Manjaro
	columnise-clever -ignore '^[^ ]* *[^ ]* *[^ ]* *[^ ]* *[^ ]* *[^ ]*' |
	# columnise-clever left-aligns fields, but we want the 5th field (file size) right-aligned
	sed 's+^\(\([^ ]* *\)\{4\}\)\([^ ]*\)\( *\) +\1\4\3 +'
else cat
fi
