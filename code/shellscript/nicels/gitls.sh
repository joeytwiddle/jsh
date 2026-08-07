#!/bin/sh
# Present output like `ls -l`, but annotate each file with its git status.

# BUG: When directories are passed as arguments, they are not listed the same as with ls.  Instead of just filenames, each file's full path is displayed.

while [ $# -gt 0 ]
do
	case "$1" in
		-l) GITLS_LONG_FORMAT=1; shift ;;
		-R) GITLS_CHECK_FOLDERS=1; shift ;;
		*) break ;;
	esac
done

# Run `git status` a single time and cache the result, instead of forking git
# once per listed file.  Clean files will not be listed in the cache.
# We write the cache to a temp file rather than exporting it, to avoid
# exceeding ARG_MAX when xargs spawns worker processes.
GITLS_CACHE_FILE=$(mktemp "${TMPDIR:-/tmp}/gitls.XXXXXX")
trap 'rm -f "$GITLS_CACHE_FILE"' EXIT

git_root="$(git rev-parse --show-toplevel 2>/dev/null)"
if [ -n "$git_root" ]
then git status --porcelain --ignored 2>/dev/null > "$GITLS_CACHE_FILE"
fi

# Porcelain paths are root-relative, but the listed paths are relative to $PWD,
# so we need the path from the repo root down to $PWD (empty when at the root).
case "$PWD" in
	"$git_root") cwd_prefix="" ;;
	*) cwd_prefix="${PWD#"$git_root"/}/" ;;
esac

GITLS_JOBS="${GITLS_JOBS:-$(nproc 2>/dev/null || getconf _NPROCESSORS_ONLN 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)}"

export GITLS_LONG_FORMAT GITLS_CHECK_FOLDERS git_root cwd_prefix GITLS_CACHE_FILE

find "$@" -maxdepth 1 |
sed 's+^\./++' |
if which sortfilesbydate >/dev/null 2>&1
then sortfilesbydate
else cat
fi |
# Emit null-delimited line-number/filename pairs for xargs -0.
# The null delimiter keeps filenames with spaces intact.
awk '{printf "%09d%c%s%c", NR, 0, $0, 0}' |
xargs -0 -n2 -P"$GITLS_JOBS" sh -c '
	lineno="$1"
	node="$2"

	# Inline rootrel: echo a listed path the way git reports it (relative to the repo root).
	case "$node" in
		/*) rootrel_node="${node#$git_root/}" ;;
		*)  rootrel_node="$cwd_prefix$node" ;;
	esac
	rootrel_node="${rootrel_node%/}"

	# Fallback (default) status.  Not many things get this.  Untracked broken symlinks do (not sure about tracked), and sockets do.
	# According to logic below, these are things which are not directories and not files.
	extra="xx"
	if [ -d "$node" ]
	then
		# Recursive mode is optional because it is a lot slower on large repositories.
		if [ -n "$GITLS_CHECK_FOLDERS" ]
		then
			# All cached lines for files below this directory.
			status_line="$(awk -v d="$rootrel_node/" '"'"'substr($0, 4, length(d)) == d'"'"' "$GITLS_CACHE_FILE")"
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
		fi
	elif [ -f "$node" ]
	then
		# Look this file up in the cached status.  An absent entry means the
		# file is clean (or we are not in a git repo), giving a blank status.
		status_line="$(awk -v p="$rootrel_node" '"'"'substr($0, 4) == p { print; exit }'"'"' "$GITLS_CACHE_FILE")"
		if [ -n "$status_line" ]
		then extra="$(printf "%s" "$status_line" | cut -c 1-2)"
		else extra="  "
		fi
	fi

	output=$(
		if [ -n "$GITLS_LONG_FORMAT" ]
		then ls -ld --color "$node" | sed "s+^\([^ ]* *\)\{8\}+\0[$extra] +"
		else ls -d --color "$node" | sed "s+^+[$extra] +"
		fi
	)
	printf "%s %s\n" "$lineno" "$output"
' _ |
sort -n |
cut -d' ' -f2- |
if [ -n "$GITLS_LONG_FORMAT" ] && which columnise-clever >/dev/null 2>&1
then
	columnise-clever -ignore '^[^ ]* *[^ ]* *[^ ]* *[^ ]* *[^ ]* *[^ ]*' |
	# columnise-clever left-aligns fields, but we want the 5th field (file size) right-aligned
	sed 's+^\(\([^ ]* *\)\{4\}\)\([^ ]*\)\( *\) +\1\4\3 +'
else cat
fi
