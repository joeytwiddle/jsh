#!/bin/sh
set -e

[ -z "$SORTBY" ] || SORTBY=modify

# stat takes different flags on GNU coreutils vs BSD/macOS
if stat -c '%Y' . >/dev/null 2>&1
then
	STAT_FLAG=-c
	case "$SORTBY" in
		access) STAT_FMT='%X %n' ;;
		status) STAT_FMT='%Z %n' ;;
		*)      STAT_FMT='%Y %n' ;;
	esac
else
	STAT_FLAG=-f
	case "$SORTBY" in
		access) STAT_FMT='%a %N' ;;
		status) STAT_FMT='%c %N' ;;
		*)      STAT_FMT='%m %N' ;;
	esac
fi

if [ -n "$1" ]
then
	echolines "$@" | sortfilesbydate
else
	# xargs -d '\n' only works on GNU systems, but this approach works on BSD/macOS systems too
	tr '\n' '\0' |
	xargs -0 -r -n 100 -P 8 stat "$STAT_FLAG" "$STAT_FMT" |

	sort -n -k 1 |
	dropcols 1
fi
